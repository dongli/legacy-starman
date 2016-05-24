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

      def self.run
        if CommandLine.options[:'update-config'].value
          DirtyWorks.handle_absent_compiler PackageLoader.installed_packages
          DirtyWorks.remove_slave_packages PackageLoader.installed_packages
          FileUtils.rm System::Shell.shell_board_file
          FileUtils.touch System::Shell.shell_board_file
          PackageLoader.installed_packages.each_value do |package|
            System::Shell.prepend 'PATH', package.bin, separator: ':', system: true if Dir.exist? package.bin
            System::Shell.prepend OS.ld_library_path, package.lib, separator: ':', system: true if Dir.exist? package.lib
            System::Shell.set "#{package.name.to_s.upcase}_ROOT", package.prefix
          end
          System::Shell.set 'PS1', '\e[0;34m\u\e[m@\e[0;32mstarman\e[m \W$ '
        else
          system "source #{System::Shell.shell_board_file} && sh"
        end
      end
    end
  end
end
