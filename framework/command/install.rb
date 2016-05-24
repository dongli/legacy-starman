module STARMAN
  module Command
    class Install
      def self.accepted_options
        {
          :'local-build' => OptionSpec.new(
            :desc => 'Force to build package locally from source codes.',
            :accept_value => { :boolean => false }
          ),
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

      def self.run
        CommandLine.packages.values.reverse_each do |package|
          next if package.has_label? :group_master
          case PackageDownloader.run package
          when :binary
            PackageBinary.run package
          when :source
            PackageInstaller.run package
          end
          # Set environment variables for later packages that depend on it.
          System::Shell.prepend 'PATH', package.bin, separator: ':', system: true if Dir.exist? package.bin
          System::Shell.append 'CPPFLAGS', "-I#{package.inc}" if Dir.exist? package.inc
          System::Shell.append 'LDFLAGS', "-L#{package.lib}" if Dir.exist? package.lib
        end
      end
    end
  end
end
