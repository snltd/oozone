# frozen_string_literal: true

require_relative 'create'

module Oozone
  module Command
    #
    # Clone one or more zones from an existing one.
    #
    class Clone < Create
      def initialize(args, opts)
        unless args.size >= 2
          abort 'Supply a zone to clone from, and one or more config files'
        end

        @src_zone = args.shift
        super
      end

      def install_or_clone
        @installer.clone!(@src_zone)
      end
    end
  end
end
