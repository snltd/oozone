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
        LOG.info "Installing '#{zone}' #{brand} zone"
        execute!("#{ZONEADM} -z #{zone} install", return_output: true)
      end

      def clone!(src_zone)
        LOG.info "Cloning '#{zone}' #{brand} zone from '#{src_zone}'"
        execute!("#{ZONEADM} -z #{zone} clone #{src_zone}", return_output: true)
      end
    end
  end
end
