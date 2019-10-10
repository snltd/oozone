require_relative 'runner'
require_relative 'constants'

# Create a dataset
#
module ZoneManager
  class DatasetManager
    include ZoneManager::Runner

    attr_reader :name

    def initialize(dataset_name)
      @name = dataset_name
    end

    def create
      return if exist?

      puts "Creating dataset '#{name}'."
      pfrun("#{ZFS} create -o mountpoint=none #{name}")
    end

    def exist?
      puts "Checking dataset '#{name}'."
      system("#{ZFS} list #{name} >/dev/null 2>&1") ? true : false
    end
  end
end
