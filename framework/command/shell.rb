module STARMAN
  module Command
    class Shell
      def self.accepted_options
        {
          :'update-config' => OptionSpec.new(
            :desc => 'Update the shell configuration file.',
            :accept_value => { :boolean => false }
          )
        }
      end

      def self.installed_packages
        if not defined? @@installed_packages
          @@installed_packages ||= []
          Dir.glob("#{ConfigStore.install_root}/*").each do |dir|
            next if not File.directory? dir
            name = File.basename(dir).to_sym
            PackageLoader.load_package name
            @@installed_packages << PackageLoader.packages[name][:instance]
          end
        end
        @@installed_packages
      end

      def self.run
        if CommandLine.options[:'update-config'].value
          p installed_packages
          debugger
        else
        end
      end
    end
  end
end
