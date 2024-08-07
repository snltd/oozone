# frozen_string_literal: true

require 'yaml'
require 'pathname'
require_relative 'dataset_manager'

module Oozone
  #
  # Convert the YAML input to a zone config file and some metadata for further
  # operations
  #
  # rubocop:disable Metrics/ClassLength
  class ConfigLoader
    attr_reader :metadata, :config, :raw

    def initialize(zone_file)
      @file = Pathname.new(zone_file)
      @raw = raw_config(zone_file)
      @metadata = { zone_name:,
                    root: Pathname.new(raw[:zonepath]).join('root') }
      @config = parsed_config
    end

    def write!(_target = zone_config_file)
      LOG.debug("dumping zone config to #{zone_config_file}")
      File.write(zone_config_file, config)
    end

    private

    def zone_config_file
      ZCONF_DIR.join(@file.basename.to_s.sub(/.yaml/, '.zone'))
    end

    def zone_name
      @file.basename.to_s.chomp('.yaml')
    end

    def raw_config(zone_file)
      LOG.debug("loading zone configuration from #{zone_file}")
      YAML.safe_load_file(zone_file, symbolize_names: true)
    rescue Errno::ENOENT
      LOG.error "file not found: #{zone_file}"
      exit 1
    end

    def parsed_config
      "#{(config_prelude + parse_input).compact.join("\n")}\n"
    end

    def parse_input
      @raw.map { |k, v| respond_to?(k, true) ? send(k, v) : simple_conv(k, v) }
    end

    def section(defns, type)
      defns.map do |defn|
        ["add #{type}"] + defn.map { |k, v| simple_conv(k, v) } + ['end']
      end
    end

    def fs(defns)
      section(defns, :fs)
    end

    def attr(defns)
      section(defns, :attr)
    end

    def net(defns)
      section(defns, :net)
    end

    def device(defns)
      section(defns, :device)
    end

    def dataset(defns)
      defns.each { |d| create_dataset(d) }
      section(defns, :dataset)
    end

    def create_dataset(dataset)
      Oozone::DatasetManager.new(dataset[:name]).create!
    end

    def simple_conv(key, value)
      if value.is_a?(Array)
        section(value, key)
      else
        ["set #{key}=#{value}"]
      end
    end

    def illumos_source(val)
      @metadata[:illumos_source] = val
      nil
    end

    def dns(defns)
      @metadata[:dns] = defns
      section([{ name: 'dns-domain',
                 type: :string,
                 value: defns[:domain] },
               { name: :resolvers,
                 type: :string,
                 value: defns[:nameserver].join(',') }], :attr)
    end

    def facts(list)
      @metadata[:facts] = list
      nil
    end

    def packages(list)
      @metadata[:packages] = list
      nil
    end

    def run_cmd(cmd)
      @metadata[:run_cmd] = cmd
      nil
    end

    def upload(files)
      @metadata[:upload] = files
      nil
    end

    def run_ssh(cmds)
      @metadata[:run_ssh] = cmds
      nil
    end

    # Used to specify a bhyve volume
    def volume_size(defns)
      @metadata[:volume_size] = defns
      nil
    end

    def raw_image(defns)
      @metadata[:raw_image] = defns
      nil
    end

    def config_prelude
      ['create -b']
    end
  end
  # rubocop:enable Metrics/ClassLength
end
