# frozen_string_literal: true

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
      run("#{ZONECFG} -z #{zone} delete -F")
    end

    def uninstall
      msg(:uninstalling)
      run("#{ZONEADM} -z #{zone} uninstall -F")
    end

    def configure
      msg(:configuring)
      run("#{ZONECFG} -z #{zone} -f #{ZCONF_DIR + "#{zone}.zone"}")
    end

    def boot
      msg(:booting)
      run("#{ZONEADM} -z #{zone} boot")
    end

    def halt
      msg(:halting)
      run("#{ZONEADM} -z #{zone} halt")
    end

    def shutdown
      msg('shutting down')
      run("#{ZONEADM} -z #{zone} shutdown")
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
        break if ready?
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
      run_for_output("#{SVCS} -z #{zone} -Ho state #{READY_SVC}") == 'online'
    end

    def state
      run("#{ZONEADM} list -cp", true).each_line do |l|
        chunks = l.split(':')
        return chunks[2] if chunks[1] == zone
      end

      nil
    end
  end
end
