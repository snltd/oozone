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

      LOG.info "Creating '#{name}' dataset"
      run("#{ZFS} create -o mountpoint=none #{name}")
    end

    def exist?
      LOG.info "Checking for '#{name}' dataset"

      if system("#{ZFS} list #{name} >/dev/null 2>&1")
        LOG.debug "'#{name}' dataset exists"
        true
      else
        LOG.debug "'#{name}' dataset does not exist"
        false
      end
    end
  end
end
