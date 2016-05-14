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
          }
        }
      end

      def self.packages_to_install
        @@packages_to_install ||= []
      end

      def self.run
        packages_to_install.reverse.each do |package|
          package.check_system
        end
      end
    end
  end
end
