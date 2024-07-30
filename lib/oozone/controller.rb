# frozen_string_literal: true

require 'pty'
require_relative 'runner'
require_relative 'constants'

module Oozone
  #
  # Control a zone: stop it start it, create it etc.
  #
  class Controller
    attr_reader :zone

    include Oozone::Runner

    def initialize(zone_name)
      @zone = zone_name
    end

    def teardown
      return not_exist unless exists?

      halt if state == 'running'
      uninstall if %w[installed incomplete].include?(state)
      delete if state == 'configured'
    end

    def msg(action)
      LOG.info "#{action.to_s.capitalize} '#{zone}' zone"
    end

    def delete
      msg(:deleting)
      zonecfg('delete -F')
    end

    def uninstall
      msg(:uninstalling)
      zoneadm('uninstall -F')
    end

    def configure
      msg(:configuring)
      zonecfg("-f #{ZCONF_DIR.join("#{zone}.zone")}")
    end

    def boot
      msg(:booting)
      zoneadm('boot')
    end

    def halt
      msg(:halting)
      zoneadm('halt')
    end

    def shutdown
      msg('shutting down')
      zoneadm('shutdown')
    end

    def exists?
      !state.nil?
    end

    def not_exist
      LOG.info "Zone '#{zone}' does not exit on this system"
    end

    def wait_for_readiness
      LOG.info 'Waiting for zone to be ready'

      loop do
        return if ready?

        sleep 2
      end
    end

    def wait_for_state(desired_state)
      LOG.info "Waiting for zone to be in state '#{desired_state}'"

      loop do
        break if state == desired_state

        sleep 2
      end
    end

    def ready?
      execute_for_output!(
        "#{SVCS} -z #{zone} -Ho state #{READY_SVC}"
      ) == 'online'
    end

    # This is a horrible hack to watch a bhyve zone boot.
    #
    def wait_for_readiness_console
      LOG.info 'Waiting for zone to be ready'

      PTY.spawn("#{ZLOGIN} -C #{zone}") do |stdout, stdin, _thr|
        stdout.each do |line|
          stdin.puts "\n" if line.include?('ttyS0')

          if line.include?(' login:')
            stdin.puts '~.'
            return true
          end
        end
      end
    end

    # @return [String, Nil] maybe shouldn't be nil?
    #
    def state
      zone_list.each_line do |l|
        chunks = l.split(':')

        return chunks[2] if chunks[1] == zone
      end

      nil
    end

    def zone_list
      execute!("#{ZONEADM} list -cp", return_output: true)
    end

    private

    def zonecfg(cmd)
      execute!("#{ZONECFG} -z #{zone} #{cmd}")
    end

    def zoneadm(cmd)
      execute!("#{ZONEADM} -z #{zone} #{cmd}")
    end
  end
end
