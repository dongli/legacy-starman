module STARMAN
  module Command
    class Download
      def self.accepted_options
        {
          :'local-build' => OptionSpec.new(
            desc: 'Force to build package locally from source codes.',
            accept_value: { boolean: false }
          ),
          :'without-depends' => OptionSpec.new(
            desc: 'Do not download dependencies.',
            accept_value: { boolean: false }
          )
        }
      end

      def self.__run__
        CommandLine.packages.each_value do |package|
          next if package.has_label? :group_master
          PackageDownloader.run package
          next unless CommandLine.options[:remote].value
          # Upload downloaded packages to remote server.
          RemoteServer.instances.each do |name, server|
            package_root = ConfigStore.config[:remote][name][:starman][:package_root]
            server.upload "#{ConfigStore.config[:package_root]}/#{package.filename}", "#{package_root}/#{package.filename}", file: true
          end
        end
      end
    end
  end
end
