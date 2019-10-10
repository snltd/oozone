require 'open3'

module ZoneManager
  module Runner
    def run(cmd, return_output = false)
      out, status = Open3::capture2e(cmd)

      if status.success?
        out if return_output
      else
        cope_with_failure(out, status.exitstatus)
      end
    end

    def pfrun(cmd, return_output = false)
      run("/bin/pfexec #{cmd}", return_output)
    end

    def cope_with_failure(output, exit_code)
      puts 'ERROR!'
      puts '---- OUTPUT BEGINS ------------------'
      puts output
      puts '---- OUTPUT ENDS --------------------'
      puts "exited #{exit_code}"
      exit exit_code
    end
  end
end
