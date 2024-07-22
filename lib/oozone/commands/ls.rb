# frozen_string_literal: true

require_relative '../runner'

module Oozone
  module Command
    #
    # Lists zones, fancy like, with some extra info
    #
    class Ls
      include Oozone::Runner

      def initialize(_arg1, _arg2)
        true
      end

      def run!
        execute_for_output!("#{ZONEADM} list -cp").each_line do |l|
          _id, name, state, root_dir, _uuid, _brand, _ip, _n = l.split(':')

          puts format('%-20<name>s %-12<state>s %-20<origin>s',
                      name:,
                      state:,
                      origin: origin(root_dir))
        end
      end

      private

      def root_dataset(root_dir)
        m = `/bin/df #{root_dir}"`.match(/.*\((.*)\).*/)
        m[1]
      rescue StandardError
        nil
      end

      def origin(root_dir)
        root_ds = root_dataset(root_dir)
        zbe_ds = File.join(root_ds, 'ROOT', 'zbe')
        origin = `#{ZFS} get -Ho value origin #{zbe_ds}`
        chunks = origin.split('/')
        root_idx = chunks.index('ROOT')
        chunks[root_idx - 1]
      rescue StandardError
        '-'
      end
    end
  end
end
