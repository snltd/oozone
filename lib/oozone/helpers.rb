# frozen_string_literal: true

require 'logger'

module Oozone
  #
  # Keep the main executable tidy by putting its methods in here.
  #
  module Helpers
    def self.execute_command(command, args, opts)
      require_relative File.join('commands', command)
      cmd_class = Object.const_get("Oozone::Command::#{command.capitalize}")
      cmd_class.new(args, opts).run!
    rescue LoadError
      abort 'Unsupported command.'
    end

    def self.ensure_privs
      return if Process.euid.zero?

      puts 'NOT RUNNING AS EUID ZERO. THINGS MAY NOT WORK! CTRL-C TO STOP.'
      sleep 3
    rescue Interrupt
      exit 0
    end

    def self.logger_object(opts)
      log = Logger.new(opts[:logfile])
      log.level = opts[:loglevel]
      log
    rescue ArgumentError => e
      abort e.message
    end
  end
end
