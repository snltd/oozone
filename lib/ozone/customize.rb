require_relative 'constants'
require_relative 'runner'

module ZoneManager
  #
  # Customize an installed zone
  #
  class Customize
    attr_reader :meta

    include ZoneManager::Runner

    # @param zname [String] zone name
    # @param meta [Hash] metadata from
    #
    def initialize(metadata)
      @meta = metadata
    end

    def customize!
      LOG.info "Configuring '#{meta[:zone_name]}' zone"
      add_facts
      configure_dns
      install_packages
      upload_files
      run_commands
    end

    private

    def add_facts
      return unless meta[:facts] && !meta[:facts].empty?

      fact_dir = meta[:root] + 'etc' + 'facter' + 'facts.d'
      fact_file = fact_dir + 'facts.txt'
      LOG.debug "MKDIR: #{fact_dir}"
      FileUtils.mkdir_p(fact_dir)
      facts = meta[:facts].map { |k, v| "#{k}=#{v}" }.join("\n")
      LOG.info "writing facts to #{fact_file}"
      File.write(fact_file, facts)
    end

    def configure_dns
      etc = meta[:root] + 'etc'
      resolv_conf = etc + 'resolv.conf'
      nsswitch_conf = etc + 'nsswitch.conf'

      LOG.info "Writing DNS config to #{resolv_conf}"
      File.write(resolv_conf, resolv_conf_content)
      LOG.info "Writing modified conf to #{nsswitch_conf}"
      File.write(nsswitch_conf, nsswitch_conf_content(nsswitch_conf))
    end

    def nsswitch_conf_content(original)
      IO.read(original).split("\n").map do |l|
        if l.start_with?('hosts') || l.start_with?('ipnodes')
          l.sub(/files.*$/, 'files dns mdns')
        else
          l
        end
      end.join("\n") + "\n"
    end

    def resolv_conf_content
      meta[:dns].map do |k, v|
        v.is_a?(Array) ? v.map { |v1| "#{k} #{v1}" } : "#{k} #{v}"
      end.join("\n") + "\n"
    end

    def install_packages
      zrun(meta[:zone_name], "#{PKG} install #{meta[:packages].join(' ')}")
    end


    def upload_files
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
      meta[:run_cmd].each { |cmd| zrun(meta[:zone_name], cmd) }
    end
  end
end
