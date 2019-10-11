require 'open3'
require 'fileutils'

module ZoneManager
  module Runner
    def run(cmd, return_output = false)
      LOG.debug "RUN: #{cmd}"
      out, status = Open3::capture2e(cmd)

      if status.success?
        out if return_output
      else
        cope_with_failure(out, status.exitstatus)
      end
    end

    def run_for_output(cmd)
      LOG.debug "RUNNING (for output): #{cmd}"
      out, _status = Open3::capture2e(cmd)
      out.strip
    end

    def zrun(zone, cmd)
      run(format('%<zlogin>s %<zone>s "%<cmd>s"',
                 zlogin: ZLOGIN,
                 zone: zone,
                 cmd: cmd.inspect))
    end

    def cope_with_failure(output, exit_code)
      LOG.fatal 'ERROR!'
      puts '---- OUTPUT BEGINS ------------------'
      puts output
      puts '---- OUTPUT ENDS --------------------'
      puts "exited #{exit_code}"
      exit exit_code
    end

    def cp(src, dest)
      unless dest.dirname.exist?
        LOG.info "MKDIR: #{dest.dirname}"
        FileUtils.mkdir_p(dest.dirname)
      end

      LOG.info "COPY: #{src} #{dest}"
      FileUtils.cp_r(src, dest)
    end
  end
end
