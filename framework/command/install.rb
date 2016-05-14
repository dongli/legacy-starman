module STARMAN
  module Command
    class Install
      def self.accepted_options
        {
          :debug => {
            :desc => 'Turn on debug stuffs, may output more information.',
            :accept_value => false
          },
          :version => {
            :desc => 'Select which version to install.',
            :accept_value => true
          },
          :force => {
            :desc => 'Force to install packages no matter other conditions.',
            :accept_value => false
          }
        }
      end

      def self.packages_to_install
        @@packages_to_install ||= []
      end

      def self.run
        packages_to_install.reverse_each do |package|
          next if not CommandLine.has_option? :force and package.check_system
        end
      end
    end
  end
end
