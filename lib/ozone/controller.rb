require_relative 'runner'
require_relative 'constants'

# Control a zone: stop it start it, create it etc.
#
module ZoneManager
  class Controller
    attr_reader :zone

    include ZoneManager::Runner

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
      run("#{ZONECFG} -z #{zone} -f #{zone}.zone")
    end

    def install
      msg(:installing)
      run("#{ZONEADM} -z #{zone} install", true)
    end

    def boot
      msg(:booting)
      run("#{ZONEADM} -z #{zone} boot")
    end

    def halt
      msg(:halting)
      run("#{ZONEADM} -z #{zone} halt")
    end

    def exists?
      !state.nil?
    end

    def not_exist
      puts "Zone '#{zone}' is not installed on this system."
    end

    def wait_for_readiness
      LOG.info "Waiting for zone to be ready"

      loop do
        break if ready?
        sleep 2
      end
    end

    def ready?
      run_for_output(
        "#{SVCS} -z #{zone} -Ho state multi-user-server:default"
      ) == 'online'
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
