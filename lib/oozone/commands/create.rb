# frozen_string_literal: true

require_relative '../controller'
require_relative '../config_loader'
require_relative '../customizer'
require_relative '../installer'
require_relative '../runner'

module Oozone
  module Command
    #
    # Create one or more zones.
    #
    class Create
      include Oozone::Runner

      # The arguments passed in to this command are a list of zone file names
      #
      def initialize(args, opts)
        @args = args
        @opts = opts
      end

      def run!
        @args.each { |z| action_zone(z) }
      end

      def using_ansible?(conf)
        conf.raw.fetch(:configure_with, 'puppet') == 'ansible'
      end

      # rubocop:disable Metrics/MethodLength
      def action_zone(zone_file)
        conf = Oozone::ConfigLoader.new(zone_file)
        zone_name = conf.metadata[:zone_name]
        zone = Oozone::Controller.new(zone_name)
        @installer = Oozone::Installer.new(conf).adapter
        @conf = conf

        return if leave_existing?(zone)

        LOG.info "creating zone '#{zone_name}'"
        conf.write!
        zone.teardown
        zone.configure
        install_or_clone
        zone.boot
        zone.wait_for_readiness
        Oozone::Customizer.new(conf).customize!
      end
      # rubocop:enable Metrics/MethodLength

      def install_or_clone
        @installer.install!
      end

      def fqdn(zone)
        "#{zone}.localnet"
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
