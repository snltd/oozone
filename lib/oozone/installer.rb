# frozen_string_literal: true

module Oozone
  #
  # Proxy class around brand-specific installers
  #
  class Installer
    attr_reader :brand, :adapter

    # @param conf [Oozone::ConfigLoader]
    #
    def initialize(conf)
      @brand = conf.raw[:brand]
      LOG.debug "looking for #{installer_file}"
      require_relative installer_file
      @adapter = installer_class.new(conf)
    rescue LoadError
      abort "'#{brand}' zones are not supported by Oozone."
    end

    def installer_file
      File.join('brand_installers', "#{brand}.rb")
    end

    def installer_class
      Object.const_get("Oozone::BrandInstaller::#{brand.capitalize}")
    end
  end
end
