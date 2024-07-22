# frozen_string_literal: true

require 'open3'
require 'fileutils'
require_relative 'constants'

module Oozone
  #
  # Mixin methods for running commands and moving stuff into zones.
  #
  module Runner
    # Run a command and dump an error if something goes wrong. Use this for
    # operations which must succeed.
    # @param cmd [String] command to run
    # @param return_output [Bool] whether or not to send back stdout on
    #   successful completion
    # @raise [Errno::ENOENT] if cmd is not a valid path
    # @raise [System::Exit] if command exits non-zero
    #
    def execute!(cmd, return_output: false)
      LOG.debug "RUN: #{cmd}"
      out, status = Open3.capture2e(cmd)

      if status.success?
        out if return_output
      else
        cope_with_failure(out, status.exitstatus)
      end
    end

    # Run a command and return true or false, depending on its exit code
    # @raise [Errno::ENOENT] if cmd is not a valid path
    #
    def executes_successfully?(cmd)
      system("#{cmd} >/dev/null 2>&1")
    end

    # Run a command and pass back the output, whether it succeeds or not.
    # @param cmd [String] command to run
    # @raise [Errno::ENOENT] if cmd is not a valid path
    # @return [String] stdout and/or stderr of command. Unlike #execute!,
    #   without trailing newline.
    #
    def execute_for_output!(cmd)
      LOG.debug "RUNNING (for output): #{cmd}"
      out, _status = Open3.capture2e(cmd)
      out.strip
    end

    # Run a command in a zone
    #
    def zexecute!(zone, cmd)
      LOG.info "running #{zone}:#{cmd}"

      execute!(format('%<zlogin>s %<zone>s %<cmd>s',
                      zlogin: ZLOGIN,
                      zone:,
                      cmd: cmd.inspect))
    end

    # Run the given command over ssh
    # @param cmd [Hash] with keys :user, :host, and :cmd, all String
    # @return nil
    #
    def ssh_execute!(cmd)
      c = "#{SSH} #{cmd[:user]}@#{cmd[:host]} '#{cmd[:cmd]}'"
      LOG.info "SSH_RUN: #{c}"

      Open3.popen3(c) do |_stdin, stdout, _stderr|
        while (line = stdout.gets)
          puts "#{cmd[:user]}@#{cmd[:host]}: #{line}"
        end
      end
    end

    # Print, log, abort
    #
    def cope_with_failure(output, exit_code)
      LOG.fatal 'ERROR!'
      puts '---- OUTPUT BEGINS ------------------'
      puts output
      puts '---- OUTPUT ENDS --------------------'
      puts "exited #{exit_code}"
      exit exit_code
    end

    # Copy a file, making a directory if necessary.
    #
    # @param src [Pathname]
    # @param dest [Pathname]
    #
    def safe_copy!(src, dest)
      unless dest.dirname.exist?
        LOG.info "MKDIR: #{dest.dirname}"
        FileUtils.mkdir_p(dest.dirname)
      end

      LOG.info "COPY: #{src} #{dest}"
      FileUtils.cp_r(src, dest)
    end
  end
end
