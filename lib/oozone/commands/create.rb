# frozen_string_literal: true

require_relative '../controller'
require_relative '../config_loader'
require_relative '../customizer'
require_relative '../installer'

module Oozone
  module Command
    #
    # Create one or more zones.
    #
    class Create
      #
      # The arguments passed in to this command are a list of zone file names
      #
      def initialize(args, opts)
        @args = args
        @opts = opts
      end

      def run!
        @args.each { |z| action_zone(z) }
      end

      # rubocop:disable Metrics/AbcSize
      # rubocop:disable Metrics/MethodLength
      def action_zone(zone_file)
        conf = Oozone::ConfigLoader.new(zone_file)
        zone_name = conf.metadata[:zone_name]
        zone = Oozone::Controller.new(zone_name)
        @installer = Oozone::Installer.new(conf).adapter

        return if leave_existing?(zone)

        LOG.info "creating zone '#{zone_name}'"
        conf.write_config
        zone.teardown
        zone.configure
        install_or_clone
        zone.boot
        zone.wait_for_readiness
        Oozone::Customizer.new(conf).customize!
      end
      # rubocop:enable Metrics/AbcSize
      # rubocop:enable Metrics/MethodLength

      def install_or_clone
        @installer.install!
      end

      def leave_existing?(zone)
        if zone.exists? && !@opts[:force]
          LOG.warn "zone '#{zone.zone}' exists. Use -F to recreate"
          true
        else
          false
        end
      end
    end
  end
end
