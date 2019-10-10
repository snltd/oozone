require 'yaml'
require_relative 'dataset_manager'

# Convert the YAML input to a zone config file and some metadata for further
# operations
#
module ZoneManager
  class ConfigLoader
    attr_reader :metadata, :config

    def initialize(file)
      @raw = YAML.safe_load(IO.read(file), symbolize_names: true)
      @file = file
      @metadata = {}
      @config = parsed_config
    end

    def parsed_config
      (config_prelude + parse_input).compact.join("\n") + "\n"
    end

    def write_config
      File.write(@file.sub(/.yaml/, '.zone'), config)
    end

    def parse_input
      @raw.map do |k, v|
        respond_to?(k) ? send(k, v) : simple_conv(k, v)
      end
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
