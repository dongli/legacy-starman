module STARMAN
  class Pip3
    extend System::Command
    extend FileUtils
    extend Utils

    def self.parse command
      args = CommandLine.option(:command).split
      CLI.report_error "Command is not #{CLI.red 'pip3'}!" if args.shift != 'pip3'
      @@command = args.shift.to_sym
      CLI.report_error "Unknown pip3 command #{CLI.red @@command}}" unless [:download, :install].include? @@command
      @@options = []
      @@wheels = []
      args.each do |arg|
        if arg =~ /^-/
          @@options << arg
        else
          @@wheels << arg
        end
      end
    end

    def self.command
      @@command ||= nil
    end

    def self.download
      @@wheels.each do |wheel|
        mkdir_p "#{ConfigStore.package_root}/#{wheel}"
        work_in "#{ConfigStore.package_root}/#{wheel}" do
          run 'pip3', 'download', *@@options, wheel
          RemoteServer.instances.each do |name, server|
            package_root = ConfigStore.config[:remote][name][:starman][:package_root]
            Dir.glob('*') do |filename|
              remote_file = "#{package_root}/#{filename}"
              next if sha_same? filename, server.sha256(remote_file)
              server.upload filename, remote_file, file: true
            end
          end
        end
      end
    end

    def self.install
      # Assume we are in offline server.
      @@wheels.each do |wheel|
        run 'pip3', 'install', '--no-index', "--find-links=#{ConfigStore.package_root}", wheel
      end
    end
  end
end