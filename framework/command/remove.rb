module STARMAN
  module Command
    class Remove
      extend FileUtils

      def self.accepted_options
        {
          :purely => OptionSpec.new(
            :desc => 'Remove package and its dependencies if they are not refered by other packages.',
            :accept_value => { :boolean => false }
          )
        }
      end

      def self.__run__
        CommandLine.packages.each_key do |package_name|
          next unless CommandLine.direct_packages.include? package_name or CommandLine.options[:purely].value
          next unless (package = PackageLoader.scan_installed_package package_name)
          PackageUninstaller.run Pathname.new(package.prefix)
        end
      end
    end
  end
end
