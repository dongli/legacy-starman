begin
  require 'net/ssh'
  require 'net/ssh/gateway'
  require 'net/sftp'
rescue LoadError
end

module STARMAN
  class RemoteServer
    def connect options = {}
      @remote = options
      if @remote[:gateway]
        @gateway = Net::SSH::Gateway.new @remote[:gateway][:host], @remote[:gateway][:user]
        @server = @gateway.ssh @remote[:host], @remote[:user]
      else
        @server = Net::SSH.start @remote[:host], @remote[:user]
      end
      CLI.report_notice "Connect to server #{CLI.blue @remote[:host]}#{" through gateway #{CLI.blue @remote[:gateway][:host]}" if @remote[:gateway]}."
    end

    def upload local_path, remote_path, options = {}
      if options[:file]
        remote_dir = Pathname.new(remote_path).dirname
      else
        if self.dir? remote_path
          remote_dir = remote_path
          if options[:force]
            self.rmdir remote_dir
          else
            CLI.report_error "Remote #{CLI.red remote_path} exists!"
          end
        end
      end
      self.mkdir remote_dir unless self.dir? remote_dir
      CLI.report_notice "Upload #{CLI.red local_path} to #{CLI.red remote_path} on server #{CLI.blue @remote[:host]}."
      @server.sftp.connect do |sftp|
        sftp.upload! local_path, remote_path do |event, uploader, *args|
          case event
          when :open
            @progressbar = ProgressBar.create(title: 'Uploading', total: args[0].size,
                                              progress_mark: '#', format: '%B %p%%',
                                              length: [CLI.width, 80].min)
          when :put
            @progressbar.progress += args[2].length
          end
        end
      end
    end

    def dir? remote_dir
      @server.exec!("test -d #{remote_dir} && echo yes").chomp == 'yes'
    end

    def mkdir remote_dir
      CLI.report_notice "Create directory #{CLI.red remote_dir} on #{CLI.blue @remote[:host]}."
      @server.exec! "mkdir -p #{remote_dir}"
    end

    def rmdir remote_dir
      CLI.report_notice "Remove directory #{CLI.red remote_dir} on #{CLI.blue @remote[:host]}."
      @server.exec! "rm -r #{remote_dir}"
    end

    def chmod remote_path, mode
      CLI.report_notice "Change #{CLI.blue remote_path} permissions to #{CLI.blue mode}."
      @server.exec! "chmod #{mode} #{remote_path}"
    end

    def command? cmd
      found = false
      @server.exec! "which #{cmd}" do |channel, stream, data|
        found = stream == :stdout
      end
      found
    end

    def sha256 remote_path
      if self.command? 'shasum'
        @server.exec!("shasum -a256 #{remote_path}").chomp.split.first
      elsif self.command? 'sha256sum'
        @server.exec!("sha256sum #{remote_path}").chomp.split.first
      end
    end

    def exec! cmd
      CLI.report_notice "Execute #{CLI.blue cmd} on #{CLI.blue @remote[:host]}."
      @server.exec! cmd
    end

    def self.init
      @@servers = {}
      CommandLine.options[:remote].value.split(',').each do |server|
        @@servers[server.to_sym] = RemoteServer.new
        @@servers[server.to_sym].connect ConfigStore.config[:remote][server.to_sym]
      end
    end

    def self.instances
      @@servers ||= {}
    end
  end
end
