# frozen_string_literal: true

require_relative 'create'

module Oozone
  module Command
    #
    # Clone one or more zones from an existing one.
    #
    class Clone < Create
      def initialize(args, opts)
        @src_zone = args.shift
        super
      end

      def install_or_clone(zone)
        zone.clone(@src_zone)
      end
    end
  end
end
