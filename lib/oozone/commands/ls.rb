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

          puts format('%-20<name>s %-12<state>s %-20<source>s',
                      name:,
                      state:,
                      source: root_dataset(root_dir))
        end
      end

      private

      def root_dataset(root_dir)
        m = execute_for_output!("/bin/df #{root_dir}").match(/.*\((.*)\).*/)
        m[1]
      end
    end
  end
end
