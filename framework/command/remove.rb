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

      def self.run
        CommandLine.packages.keys.reverse_each do |package_name|
          next unless CommandLine.direct_packages.include? package_name or CommandLine.options[:purely].value
          next unless (package = PackageLoader.scan_installed_package package_name)
          rm_r package.prefix
          # Check if there is other instances installed with same version.
          path = Pathname.new(package.prefix).dirname
          if path.children.empty?
            rm_r path
            # Check if there is other versions installed.
            path = path.dirname
            if path.children.empty?
              rm_r path
            end
          end
          CLI.report_notice "Package #{CLI.blue package_name} (#{CLI.red package.prefix}) has been removed."
        end
      end
    end
  end
end
