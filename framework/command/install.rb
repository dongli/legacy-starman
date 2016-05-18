module STARMAN
  module Command
    class Install
      def self.accepted_options
        {
          :version => OptionSpec.new(
            :desc => 'Select which version to install.',
            :accept_value => :string
          ),
          :force => OptionSpec.new(
            :desc => 'Force to install packages no matter other conditions.',
            :accept_value => { :boolean => false }
          )
        }
      end

      def self.packages_to_install
        @@packages_to_install ||= []
      end

      def self.run
        packages_to_install.reverse_each do |package|
          next if not CommandLine.has_option? :force and package.check_system
          PackageDownloader.run package
        end
      end
    end
  end
end
