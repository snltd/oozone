# frozen_string_literal: true

require_relative '../runner'

module Oozone
  module BrandInstaller
    #
    # Install or clone ipkg zones
    #
    class Ipkg
      attr_reader :zone, :brand, :conf

      include Oozone::Runner

      def initialize(conf)
        @zone = conf.metadata[:zone_name]
        @brand = conf.raw[:brand]
        @conf = conf
      end

      def install!
        install_message
        run("#{ZONEADM} -z #{zone} install", true)
      end

      def clone!(src_zone)
        clone_message(src_zone)
        run("#{ZONEADM} -z #{zone} clone #{src_zone}", true)
      end

      def install_message
        LOG.info "Installing '#{zone}' #{brand} zone"
      end

      def clone_message(src_zone)
        LOG.info "Cloning '#{zone}' #{brand} zone from '#{src_zone}'"
      end
    end
  end
end
