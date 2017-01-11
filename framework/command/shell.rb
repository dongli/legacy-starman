module STARMAN
  module Command
    class Shell
      extend FileUtils

      def self.accepted_options
        {
          :'update-config' => OptionSpec.new(
            desc: 'Update the shell configuration file.',
            accept_value: { boolean: false }
          ),
          :'compiler-set' => OptionSpec.new(
            desc: 'Choose which compiler set to be active.',
            accept_value: { integer: -1 }
          )
        }
      end

      def self.__run__
        if CommandLine.options[:'compiler-set'].value == -1
          CommandLine.options[:'compiler-set'].check ConfigStore.defaults[:compiler_set_index]
        end
        CompilerStore.set_active_compiler_set CommandLine.options[:'compiler-set'].value
        System::Shell.reset_rc_file
        if CommandLine.options[:'update-config'].value
          DirtyWorks.handle_absent_compiler PackageLoader.installed_packages
          DirtyWorks.remove_slave_packages PackageLoader.installed_packages
          rm_f System::Shell.rc_file
          touch System::Shell.rc_file
          PackageLoader.installed_packages.each_value do |package|
            System::Shell.set "#{package.name.to_s.upcase}_ROOT", package.prefix
            next if package.has_label? :system_conflict
            System::Shell.prepend 'PATH', package.bin, separator: ':', system: true if Dir.exist? package.bin
            System::Shell.prepend 'MANPATH', package.man, separator: ':', system: true if Dir.exist? package.man
            System::Shell.prepend OS.ld_library_path, package.lib, separator: ':', system: true if Dir.exist? package.lib and not package.has_label? :system_conflict
            System::Shell.prepend 'PKG_CONFIG_PATH', package.pkg_config, separator: ':', system: true if Dir.exist? package.pkg_config
            package.export_env
            # Let slaves have opportunity to export their environment variables.
            package.slaves.each(&:export_env) if package.has_label? :group_master
          end
          System::Shell.default_environment_variables
        else
          system "bash --rcfile #{System::Shell.rc_file}"
        end
      end
    end
  end
end
