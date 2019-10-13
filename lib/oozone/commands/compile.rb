# frozen_string_literal: true

require_relative 'create'

module Oozone
  module Command
    #
    # Turn a YAML file into a zonecfg file. This command is not very useful
    # outside of testing Oozone.
    #
    class Compile < Create
      def action_zone(zone_file)
        conf = Oozone::ConfigLoader.new(zone_file)
        LOG.info "dumping zone file to #{ZCONF_DIR}"
        conf.write_config
      end
    end
  end
end
