# frozen_string_literal: true

require 'erb'
require 'pathname'
require_relative 'ipkg'
require_relative '../constants'

module Oozone
  module BrandInstaller
    #
    # Build a bhyve zone from a Cloud-init-ready image, configuring the network
    # and whatnot from ERB template files.
    #
    # rubocop:disable Metrics/ClassLength
    class Bhyve < Ipkg
      # rubocop:disable Metrics/AbcSize
      def install!
        volume_size = conf.metadata.fetch(:volume_size, nil)
        abort 'no volume_size' if volume_size.nil?

        dataset = "#{VOLUME_ROOT_DS}/#{zone}"

        create_volume(volume_size, dataset)
        src = conf.metadata.fetch(:raw_image, nil)
        abort 'No raw_image in zone config' if src.nil?
        write_raw_image(src, dataset)
        create_cloudinit_iso
        execute!("#{ZONEADM} -z #{zone} install")
        rewrite_zone_config
      end
      # rubocop:enable Metrics/AbcSize

      def create_volume(size, dataset)
        if executes_successfully?("#{ZFS} list #{dataset}")
          LOG.info("dataset #{dataset} already exists")
          return false
        end

        LOG.info("Creating #{size} dataset '#{dataset}'")
        execute!("#{ZFS} create -V #{size} #{dataset}")
      end

      def write_raw_image(src, dataset)
        ds_target = "/dev/zvol/dsk/#{dataset}"
        LOG.info("Copying #{src} to #{ds_target}")
        execute!("/bin/cat #{src} >#{ds_target}")
      end

      def rewrite_zone_config
        LOG.info('Removing cloud-init CD-ROM from zone')
        execute!("#{ZONECFG} -z #{@zone} remove attr name=cdrom")
        execute!("#{ZONECFG} -z #{@zone} remove fs type=lofs")
      end

      def create_cloudinit_iso
        img_dir = create_cloudinit_img_dir
        create_cloudinit_iso_from_dir(
          img_dir,
          conf.metadata[:cloudinit_iso_file]
        )
      end

      def fresh_cloudinit_iso_dir(cloudinit_iso_dir = nil)
        cloudinit_iso_dir = cloudinit_tmp if cloudinit_iso_dir.nil?

        if cloudinit_iso_dir.exist?
          LOG.info("Flushing #{cloudinit_iso_dir}")
          FileUtils.rm_rf(cloudinit_iso_dir)
        end

        Pathname.new(FileUtils.mkdir_p(cloudinit_iso_dir).first)
      rescue StandardError
        LOG.error "Cannot create cloud-init dir #{cloudinit_iso_dir}"
        nil
      end

      # rubocop:disable Metrics/MethodLength
      def cloudinit_src_dir(root_dir = Pathname.new('cloud-init'), zone = @zone)
        instance_dir = cloudinit_dir(root_dir, zone)
        common_dir = cloudinit_dir(root_dir, 'common')

        if instance_dir.exist?
          LOG.info "Using image-specific cloud-init config in #{instance_dir}"
          instance_dir
        elsif common_dir.exist?
          LOG.info "Using common cloud-init config in #{common_dir}"
          common_dir
        else
          LOG.error "No cloudinit dir. (Tried #{instance_dir}, #{common_dir}"
          nil
        end
      rescue Errno::ENOENT
        LOG.error "Failed to resolve #{root_dir}"
        nil
      end
      # rubocop:enable Metrics/MethodLength

      def create_cloudinit_img_dir(src_dir = nil, target_dir = nil)
        src_dir ||= cloudinit_src_dir
        target_dir = fresh_cloudinit_iso_dir(target_dir)

        return if target_dir.nil? || src_dir.nil?

        LOG.info("Constructing cloud-init CDROM in #{target_dir}")

        src_dir.children.each do |f|
          render_cloudinit_template(f, target_dir.join(f.basename))
        end

        target_dir
      end

      def create_cloudinit_iso_from_dir(src_dir, target_file)
        cmd = "#{MKISOFS} -output #{target_file} -volid cidata " \
              "-joliet -rock #{src_dir}/"

        execute!(cmd)
      end

      private

      def render_cloudinit_template(src, dest)
        File.write(dest, ERB.new(File.read(src)).result_with_hash(erb_binding))
      end

      # Just to be explicit
      def erb_binding
        netconf = @conf.raw[:net].first
        {
          zone: @zone,
          ip_address: netconf[:'allowed-address'],
          gateway: netconf[:defrouter],
          default_router: netconf[:defrouter]
        }
      rescue StandardError
        raise 'Cannot parse network config for ERB binding'
      end

      def cloudinit_tmp
        Pathname.new('/tmp').join(conf.metadata[:zone_name])
      end

      def cloudinit_dir(root_dir, zone_name)
        root_dir.join(zone_name).realdirpath
      end
    end
    # rubocop:enable Metrics/ClassLength
  end
end
