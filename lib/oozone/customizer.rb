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
      @fact_dir = meta[:root].join('etc', 'ansible', 'facts.d')
      @fact_file = fact_dir.join('zone.fact')
    end

    def customize!
      LOG.info "Configuring '#{meta[:zone_name]}' zone"
      add_facts
      install_packages
      upload_files
      run_commands
      run_ssh
    end

    def add_facts
      return unless meta.key?(:facts)

      mk_fact_dir
      write_fact_file
    end

    def install_packages
      return unless meta.key?(:packages)

      LOG.info "installing packages: #{meta[:packages].join(', ')}"
      zexecute!(meta[:zone_name], "#{PKG} install #{meta[:packages].join(' ')}")
    end

    def upload_files
      return unless meta.key?(:upload)

      meta[:upload].each do |src, dest|
        src = Pathname.new(src.to_s)

        unless src.exist?
          LOG.info "#{src} does not exist"
          next
        end

        safe_copy!(src, meta[:root].join(dest[1..]))
      end
    end

    def run_commands
      return unless meta.key?(:run_cmd)

      meta[:run_cmd].each { |cmd| zexecute!(meta[:zone_name], cmd) }
    end

    def run_ssh
      return unless meta.key?(:run_ssh)

      meta[:run_ssh].each { |cmd| ssh_execute!(cmd) }
    end

    private

    def write_fact_file
      LOG.info "writing facts to #{fact_file}"
      File.write(fact_file, fact_file_content)
    end

    def mk_fact_dir
      LOG.debug "MKDIR: #{fact_dir}"
      FileUtils.mkdir_p(fact_dir)
    end

    def fact_file_content
      content = ['[general]', "zbrand=#{zone_conf.raw[:brand]}"]
      meta[:facts].each { |k, v| content << "#{k}=#{v}" } if meta.key?(:facts)
      content.join("\n")
    end
  end
end
