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
      halt if state == 'running'
      uninstall if %w[installed incomplete].include?(state)
      delete if state == 'configured'
    end

    def msg(action)
      puts "#{action.to_s.capitalize} zone '#{zone}'."
    end

    def delete
      msg(:deleting)
      pfrun("#{ZONECFG} -z #{zone} delete -F")
    end

    def uninstall
      msg(:uninstalling)
      pfrun("#{ZONEADM} -z #{zone} uninstall -F")
    end

    def configure
      msg(:configuring)
      pfrun("#{ZONECFG} -z #{zone} -f #{zone}.zone")
    end

    def install
      msg(:installing)
      pfrun("#{ZONEADM} -z #{zone} install", true)
    end

    def boot
      msg(:booting)
      pfrun("#{ZONEADM} -z #{zone} boot")
    end

    def halt
      msg(:halting)
      pfrun("#{ZONEADM} -z #{zone} halt")
    end

    def exists?
      !state.nil?
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
