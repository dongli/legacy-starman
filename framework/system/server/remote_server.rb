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
        @server = @gateway.ssh @remote[:server][:host], @remote[:server][:user]
      else
        @server = Net::SSH.start @remote[:server][:host], @remote[:server][:user]
      end
      CLI.report_notice "Connect to server #{CLI.blue @remote[:server][:host]}#{" through gateway #{CLI.blue @remote[:gateway][:host]}" if @remote[:gateway]}."
    end

    def upload local_path, remote_path
      remote_mkdir remote_path if not remote_dir? remote_path
      CLI.report_notice "Upload #{CLI.red local_path} to #{CLI.red remote_path} on server #{CLI.blue @remote[:server][:host]}."
      @server.sftp.connect do |sftp|
        sftp.upload! local_path, remote_path
      end
    end

    def remote_dir? remote_path
      @server.exec!("test -d #{remote_path} && echo yes").chomp == 'yes'
    end

    def remote_mkdir remote_path
      CLI.report_notice "Create directory #{CLI.red remote_path} on #{CLI.blue @remote[:server][:host]}."
      @server.exec! "mkdir -p #{remote_path}"
    end
  end
end
