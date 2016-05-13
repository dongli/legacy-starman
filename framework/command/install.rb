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

      def self.run
        CommandLine.packages.each do |name|
          package = eval("#{name.capitalize}").new
          debugger
        end
      end
    end
  end
end
