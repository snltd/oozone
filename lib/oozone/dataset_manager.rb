# frozen_string_literal: true

require_relative 'runner'
require_relative 'constants'

module Oozone
  #
  # Manage ZFS datasets. These are datasets passed through to the zone, not
  # the ones on which the zone itself is built.
  #
  class DatasetManager
    include Oozone::Runner

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
