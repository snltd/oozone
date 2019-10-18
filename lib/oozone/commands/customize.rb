# frozen_string_literal: true

require_relative 'create'

module Oozone
  module Command
    #
    # Customize one or more zones. The zones must already exist, and this
    # command is not very useful outside of testing Oozone.
    #
    class Customize < Create
      def action_zone(zone_file)
        conf = Oozone::ConfigLoader.new(zone_file)
        zone = Oozone::Controller.new(conf.metadata[:zone_name])
        exists?(zone)
        Oozone::Customizer.new(conf).customize!
      end

      def exists?(zone)
        return if zone.exists?

        LOG.error 'zone is not installed'
        exit 3
      end
    end
  end
end
