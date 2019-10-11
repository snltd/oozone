# frozen_string_literal: true

require_relative 'create'

module Oozone
  module Command
    #
    # Destroy one or more zones. Currently any external datasets are left
    # undisturbed.
    #
    class Destroy < Create
      def action_zone(zone_name)
        LOG.info("destroying zone '#{zone_name}'")
        Oozone::Controller.new(zone_name).teardown
      end
    end
  end
end
