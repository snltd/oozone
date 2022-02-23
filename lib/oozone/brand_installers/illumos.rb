# frozen_string_literal: true

require_relative 'ipkg'

module Oozone
  module BrandInstaller
    #
    # Illumos zones require a source to build from. It can be an existing
    # zone, a ZFS snapshot, a ZFS datastream, or a tarfile. (Which we don't
    # support because I don't need it.)
    #
    # We have our users specify the source in the `illumos_source` parameter of
    # their zone config file.
    #
    class Illumos < Ipkg
      def install!
        install_message
        run("#{ZONEADM} -z #{zone} install -s #{source}", true)
      end

      def source
        if conf.metadata.key?(:illumos_source)
          file = Pathname.new(conf.metadata[:illumos_source])
          file.absolute? ? file : Pathname.pwd + file
        else
          abort "Config file must contain 'illumos_source' key"
        end
      end
    end
  end
end
