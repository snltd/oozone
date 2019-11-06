# frozen_string_literal: true

require_relative 'constants'
require_relative 'runner'

module Oozone
  #
  # Customize an installed zone
  #
  class Customizer
    attr_reader :meta, :fact_dir, :fact_file, :zone_conf

    include Oozone::Runner

    # @param zone_conf [Oozone::ConfigLoader] configuration of zone
    #
    def initialize(zone_conf)
      @zone_conf = zone_conf
      @meta = zone_conf.metadata
      @fact_dir = meta[:root] + 'etc' + 'facter' + 'facts.d'
      @fact_file = fact_dir + 'facts.txt'
    end

    def customize!
      LOG.info "Configuring '#{meta[:zone_name]}' zone"
      add_facts
      install_packages
      upload_files
      run_commands
    end

    private

    def add_facts
      return unless meta[:facts] && !meta[:facts].empty?

      mk_fact_dir
      write_fact_file
    end

    def write_fact_file
      LOG.info "writing facts to #{fact_file}"
      File.write(fact_file, fact_file_content)
    end

    def mk_fact_dir
      LOG.debug "MKDIR: #{fact_dir}"
      FileUtils.mkdir_p(fact_dir)
    end

    def fact_file_content
      { zbrand: zone_conf.raw[:brand] }.merge(meta[:facts]).map do |k, v|
        "#{k}=#{v}"
      end.join("\n")
    end

    def install_packages
      return unless meta.key?(:packages)

      LOG.info "installing packages: #{meta[:packages].join(', ')}"
      zrun(meta[:zone_name], "#{PKG} install #{meta[:packages].join(' ')}")
    end

    def upload_files
      return unless meta.key?(:upload)

      meta[:upload].each do |src, dest|
        src = Pathname.new(src.to_s)

        unless src.exist?
          puts "#{src} does not exist"
          next
        end

        zdest = meta[:root] + dest[1..-1]
        cp(src, zdest)
      end
    end

    def run_commands
      return unless meta.key?(:run_cmd)

      meta[:run_cmd].each do |cmd|
        LOG.info "running #{cmd}"
        zrun(meta[:zone_name], cmd)
      end
    end
  end
end
