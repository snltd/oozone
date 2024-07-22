# frozen_string_literal: true

require_relative 'ipkg'

module Oozone
  module BrandInstaller
    #
    # This requires an extra field disk_size
    #
    class Bhyve < Ipkg
      def install!
        volume_size = conf.metadata.fetch(:volume_size, nil)
        abort 'no volume_size' if volume_size.nil?

        dataset = "#{VOLUME_ROOT_DS}/#{zone}"

        create_volume(volume_size, dataset)
        src = conf.metadata.fetch(:raw_image, nil)
        abort 'No raw_image in zone config' if src.nil?
        write_raw_image(src, dataset)

        execute!("#{ZONEADM} -z #{zone} install")
      end

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
        execute!("/bin/pv #{src} > #{ds_target}")
      end
    end
  end
end
