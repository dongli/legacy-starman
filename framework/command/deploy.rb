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
        if system_command? :git
          git_sha = run('git', "--git-dir=#{ENV['STARMAN_ROOT']}/.git", 'rev-parse', 'origin/master', :capture_output).chomp
          tar_name = "starman.#{git_sha}.tgz"
          work_in ConfigStore.config[:package_root] do
            unless File.exist? tar_name
              CLI.report_notice "Pack STARMAN in #{ConfigStore.config[:package_root]}."
              run "git clone #{ENV['STARMAN_ROOT']}"
              compress 'starman', tar_name
              rm_r 'starman'
            end
          end
        else
          tar_name = 'starman.tgz'
          work_in ConfigStore.config[:package_root] do
            compress ENV['STARMAN_ROOT'], tar_name
          end
        end
        RemoteServer.instances.each do |name, server|
          location = ConfigStore.config[:remote][name][:starman][:location]
          local_tgz = "#{ConfigStore.config[:package_root]}/starman.#{git_sha}.tgz"
          remote_tgz = "#{location}/.tmp/starman.#{git_sha}.tgz"
          if not server.dir? location or CommandLine.option :force
            # Backup existing files.
            remote_config_file = "#{location}/starman.config"
            if server.file? remote_config_file
              server.cp remote_config_file, "#{location}/.."
            else
              remote_config_file = nil
            end
            remote_ruby_dir = "#{location}/ruby"
            if server.dir? remote_ruby_dir
              server.cp remote_ruby_dir, "#{location}/.."
            else
              remote_ruby_dir = nil
            end
            server.rmdir location
            server.upload local_tgz, remote_tgz, file: true
            server.exec! "tar xf #{remote_tgz} -C #{location}"
            server.exec! "rm -rf #{location}/.tmp"
            # Copy back backup files.
            if remote_config_file
              server.mv "#{location}/../starman.config", location
            end
            if remote_ruby_dir
              server.mv "#{location}/../ruby", location
            else
              ruby_tgz = "#{ConfigStore.config[:package_root]}/ruby-2.4.0.tar.gz"
              server.upload ruby_tgz, "#{location}/ruby/" unless is_ruby_ok? server
            end
          else
            CLI.report_warning "Already uploaded, use -force to override."
          end
        end
      end

      def self.is_ruby_ok? server
        return false unless server.command? 'ruby'
        version = VersionSpec.new(server.exec!('ruby -v').match(/(\d+)\.(\d+)\.(\d+)/)[0])
        version >= '2.0.0'
      end
    end
  end
end
