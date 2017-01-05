module STARMAN
  module Command
    class Deploy
      extend System::Command
      extend FileUtils

      def self.accepted_options
        {
          force: OptionSpec.new(
            desc: 'Delete the old copy on the server if there is.',
            accept_value: { boolean: false }
          )
        }
      end

      def self.__run__
        git_sha = run('git', "--git-dir=#{ENV['STARMAN_ROOT']}/.git", 'rev-parse', 'origin/master', :capture_output).chomp
        work_in ConfigStore.config[:package_root] do
          unless File.exist? "starman.#{git_sha}.tgz"
            CLI.report_notice "Pack STARMAN in #{ConfigStore.config[:package_root]}."
            run "git clone #{ENV['STARMAN_ROOT']}"
            compress 'starman', "starman.#{git_sha}.tgz"
            rm_r 'starman'
          end
        end
        RemoteServer.instances.each do |name, server|
          location = ConfigStore.config[:remote][name][:starman][:location]
          local_tgz = "#{ConfigStore.config[:package_root]}/starman.#{git_sha}.tgz"
          remote_tgz = "#{location}/.tmp/starman.#{git_sha}.tgz"
          if not server.dir? location or CommandLine.options[:force].value
            server.rmdir location
            server.upload local_tgz, remote_tgz, file: true
            server.exec! "tar xf #{remote_tgz} -C #{location}"
            server.exec! "rm -rf #{location}/.tmp"
          else
            CLI.report_warning "Already uploaded, use -force to override."
          end
        end
      end
    end
  end
end
