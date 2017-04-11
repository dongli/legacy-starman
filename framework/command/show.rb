module STARMAN
  module Command
    class Show
      def self.accepted_options
        {}
      end

      def self.__run__
        CommandLine.direct_packages.each_value do |package|
          profile = PackageProfile.read_profile package.prefix
          CLI.blue_arrow "name: #{profile[:name]}"
          CLI.blue_arrow "version: #{profile[:version]}"
          CLI.blue_arrow "revision: #{profile[:revision].keys.first}"
          CLI.blue_arrow "built by: #{profile[:compiler_tag]}"
          CLI.blue_arrow "built for: #{profile[:os_tag]}"
          CLI.blue_arrow "options: #{profile[:options]}"
        end
      end
    end
  end
end
