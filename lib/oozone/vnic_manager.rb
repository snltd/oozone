require_relative 'constants'
require_relative 'runner'

module Oozone
  #
  # Unlike Solaris, OmniOS `zoneadm` does not create VNICs for use
  # exclusive IP stack zones. This class works out whether one is needed, and
  # if so, makes it on the appropriate physical NIC. It's not particularly
  # clever about picking the NIC. (See #auto_nic.)
  #
  # Our VNIC naming scheme is of the form <nic>_zonename so, for instance,
  # rge0_wavefront, e1000g1_media. This isn't the clearest, but OmniOS only
  # lets you use alphanumerics and underscores, so what can you do?
  #
  class VnicManager
    attr_reader :conf, :auto_nic_name, :zone_name

    include Oozone::Runner

    # @param raw_conf is the parsed YAML file which describes the zone
    #
    def initialize(zone_name, raw_conf = {})
      @zone_name = safe_name(zone_name)
      @conf = raw_conf
      @auto_nic_name = nil
    end

    def setup!
      if shared_ip?
        LOG.info 'shared IP requested'
      else
        vnic_map.each { |gnic, znic| configure_vnic(gnic, znic) }
      end
    end

    # This isn't as smart as it could be. It destroys any VNIC matching our
    # naming scheme.
    #
    def destroy!
      if shared_ip?
        LOG.info 'shared IP requested'
      else
        extant_zone_vnics(zone_name).each { |vnic| destroy_vnic(vnic) }
      end
    end

    def extant_zone_vnics(zone_name)
      run("#{DLADM} show-vnic -polink", true).split("\n").select do |vnic|
        vnic =~ /^[a-z0-9]+\d+_#{zone_name}_[a-z0-9]+\d+$/
      end
    end

    def destroy_vnic(vnic)
      LOG.info "Destroying VNIC #{vnic}"
      run("#{DLADM} delete-vnic #{vnic}")
    end

    # @return [Bool] does this zone want to use a shared IP stack?
    #
    def shared_ip?
      conf.key?(:'ip-type') && conf[:'ip-type'] == 'shared'
    end

    # Confusingly, zonecfg uses "physical" for the name of the VNIC inside the
    # zone.
    # @return [Hash] physical_nic => VNIC_name
    #
    def vnic_map
      return {} unless conf.key?(:net)

      conf[:net].each_with_object({}) do |net, a|
        next unless net.key?(:'global-nic') && net.key?(:physical)
        global = net[:'global-nic']
        global = auto_nic if global == 'auto'
        a[global] = "#{global}_#{zone_name}_#{net[:physical]}"
      end
    end

    def configure_vnic(physical_nic, vnic_name)
      LOG.info "configuring VNIC #{vnic_name} on #{physical_nic}"
      run("#{DLADM} create-vnic -l #{physical_nic} #{vnic_name}")
    end

    # You could be cute here and on a multi-homed box, work out what NIC
    # ought to host a given address, but I don't need to be. I'm just going to
    # assume the first NIC is the default and cache it.
    #
    def auto_nic
      return auto_nic_name if auto_nic_name

      @auto_nic_name = dladm_info.lines.first.strip
    end

    # Broken out for simpler stubbing
    #
    def dladm_info
      run("#{DLADM} show-phys -po link", true)
    end

    # OmniOS VNIC names can only have alphanumerics and underscores.
    #
    def safe_name(zone_name)
      zone_name.tr('-', '_').gsub(/\W/, '')
    end
  end
end

