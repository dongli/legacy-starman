module STARMAN
  module Command
    class Deploy
      extend Utils

      def self.accepted_options
        {
          remote: OptionSpec.new(
            desc: 'Provide a YAML format configuration file for deploy STARMAN.',
            accept_value: :path
          )
        }
      end

      def self.run
        @@remote = symbolize_keys YAML.load(File.read(CommandLine.options[:remote].value)).to_hash
        @@server = RemoteServer.new
        @@server.connect @@remote
        @@server.upload ENV['STARMAN_ROOT'], @@remote[:starman][:location]
      end
    end
  end
end
