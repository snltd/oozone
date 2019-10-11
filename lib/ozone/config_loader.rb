require 'yaml'
require 'pathname'
require_relative 'dataset_manager'

module ZoneManager
  #
  # Convert the YAML input to a zone config file and some metadata for further
  # operations
  #
  class ConfigLoader
    attr_reader :metadata, :config

    def initialize(zone_name)
      file = "#{zone_name}.yaml"
      LOG.debug("loading zone configuration from #{file}")
      @raw = YAML.safe_load(IO.read(file), symbolize_names: true)
      @file = file
      @metadata = { zone_name: zone_name,
                    root: Pathname.new(@raw[:zonepath]) + 'root' }
      @config = parsed_config
    end

    def parsed_config
      (config_prelude + parse_input).compact.join("\n") + "\n"
    end

    def write_config
      config_file = Pathname.new(@file.sub(/.yaml/, '.zone')).realpath
      LOG.debug("dumping zone config to #{config_file}")
      File.write(config_file, config)
    end

    def parse_input
      @raw.map { |k, v| respond_to?(k) ? send(k, v) : simple_conv(k, v) }
    end

    def section(defns, type)
      defns.map do |defn|
        ["add #{type}"] + defn.map { |k, v| simple_conv(k, v) } + ['end']
      end
    end

    def fs(defns)
      section(defns, :fs)
    end

    def net(defns)
      section(defns, :net)
    end

    def dataset(defns)
      defns.each do |dataset|
        ZoneManager::DatasetManager.new(dataset[:name]).create
      end

      section(defns, :dataset)
    end

    def simple_conv(key, value)
      ["set #{key}=#{value}"]
    end

    def dns(defns)
      @metadata[:dns] = defns
      nil
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

    def config_prelude
      ['create -b']
    end
  end
end
