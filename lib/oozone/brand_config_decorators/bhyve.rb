# frozen_string_literal: true

module Oozone
  module ConfigDecorator
    # The bhyve installer is strongly opinionated. Here it fills in most of
    # the zone config file for you.
    class Bhyve
      def initialize(config, metadata)
        @config = config
        @metadata = metadata
        @bootdisk = File.join('rpool', 'zones', 'bhyve', @metadata[:zone_name])
        @cloud_init_iso = '/tmp/cloud-init.iso' # THIS WILL BE DYNAMIC
      end

      def decorate!
        ret = add_zvol_device(@config)
        ret = add_cloudinit_cdrom(ret) if @metadata[:cloudinit]
        add_boot_attrs(ret)
      end

      # rubocop:disable Metrics/MethodLength
      def add_boot_attrs(config)
        to_add = [
          ['add attr',
           ['set name=bootrom'],
           ['set type=string'],
           ['set value=BHYVE_RELEASE'],
           'end'],
          ['add attr',
           ['set name=bootdisk'],
           ['set type=string'],
           ["set value=#{@bootdisk}"],
           'end'],
          ['add attr',
           ['set name=acpi'],
           ['set type=string'],
           ['set value=false'],
           'end']
        ]

        if @metadata[:cloudinit]
          to_add << ['add attr',
                     ['set name=cdrom'],
                     ['set type=string'],
                     ["set value=#{@cloud_init_iso}"],
                     'end']
        end

        config << to_add
      end
      # rubocop:enable Metrics/MethodLength

      def add_cloudinit_cdrom(config)
        config << [
          ['add fs',
           ["set dir=#{@cloud_init_iso}"],
           ["set special=#{@cloud_init_iso}"],
           ['set type=lofs'],
           ['set options=ro'],
           'end']
        ]
      end

      def add_zvol_device(config)
        config << [
          ['add device', ["set match=/dev/zvol/rdsk/#{@bootdisk}"], 'end']
        ]
      end
    end
  end
end
