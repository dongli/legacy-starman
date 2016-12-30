module STARMAN
  module Command
    class Deploy
      extend Utils

      def self.accepted_options
        {}
      end

      def self.run
        @@remote = ConfigStore.config[:remote][CommandLine.options[:remote].value.to_sym]
        @@server = RemoteServer.new
        @@server.connect @@remote
        @@server.upload ENV['STARMAN_ROOT'], @@remote[:starman][:location]
        @@server.chmod "#{@@remote[:starman][:location]}/setup.sh", '774'
        @@server.chmod "#{@@remote[:starman][:location]}/starman", '774'
      end
    end
  end
end
