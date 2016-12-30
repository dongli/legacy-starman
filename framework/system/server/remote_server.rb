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

    def upload local_path, remote_path
      if self.dir? remote_path
        CLI.report_error "Remote #{CLI.red remote_path} exists!"
      else
        self.mkdir remote_path
        CLI.report_notice "Upload #{CLI.red local_path} to #{CLI.red remote_path} on server #{CLI.blue @remote[:host]}."
        @server.sftp.connect do |sftp|
          sftp.upload! local_path, remote_path
        end
      end
    end

    def dir? remote_path
      @server.exec!("test -d #{remote_path} && echo yes").chomp == 'yes'
    end

    def mkdir remote_path
      CLI.report_notice "Create directory #{CLI.red remote_path} on #{CLI.blue @remote[:host]}."
      @server.exec! "mkdir -p #{remote_path}"
    end

    def chmod remote_path, mode
      CLI.report_notice "Change #{CLI.blue remote_path} permissions to #{CLI.blue mode}."
      @server.exec! "chmod #{mode} #{remote_path}"
    end
  end
end
