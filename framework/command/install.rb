module STARMAN
  module Command
    class Install
      extend System::Command

      def self.accepted_options
        {
          :'local-build' => OptionSpec.new(
            desc: 'Force to build package locally from source codes.',
            accept_value: { boolean: false }
          ),
          version: OptionSpec.new(
            desc: 'Select which version to install.',
            accept_value: :string
          ),
          force: OptionSpec.new(
            desc: 'Force to install packages no matter other conditions.',
            accept_value: { boolean: false }
          ),
          post: OptionSpec.new(
            desc: 'Only execute post install procedures.',
            accept_value: { boolean: false }
          )
        }
      end

      def self.__run__
        System::Shell.whitelist ['PATH', OS.ld_library_path, 'PKG_CONFIG_PATH'], separator: ':'
        CommandLine.packages.each_value do |package|
          if package.has_label? :group_master
            PackageProfile.write_profile package # Record the group master profile.
            next
          end
          # Skip installation if package has system_first label.
          next if skip? package
          case PackageDownloader.run package
          when :binary
            installed = PackageBinary.run package
          when :source
            installed = PackageInstaller.run package
          end
          package.post_install if not installed and CommandLine.options[:post].value
          # Set environment variables for later packages that depend on it.
          System::Shell.prepend 'PATH', package.bin, separator: ':' if Dir.exist? package.bin
          System::Shell.prepend OS.ld_library_path, package.lib, separator: ':' if Dir.exist? package.lib and not package.has_label? :system_conflict
          System::Shell.prepend 'PKG_CONFIG_PATH', package.pkg_config, separator: ':' if Dir.exist? package.pkg_config
          System::Shell.append 'CPPFLAGS', "-I#{package.inc}" if Dir.exist? package.inc
          System::Shell.append 'LDFLAGS', "-L#{package.lib}" if Dir.exist? package.lib
          # Handle compiler package.
          next unless installed and package.has_label? :compiler
          new_compiler_set_index = :"compiler_set_#{CompilerStore.compiler_sets.size}"
          ConfigStore.config[new_compiler_set_index] = {}
          package.shipped_compilers.each do |language, command|
            ConfigStore.config[new_compiler_set_index][language] = "#{package.bin}/#{command}"
          end
          ConfigStore.write_config
        end
      end

      private

      def self.skip? package
        return false unless package.has_label? :system_first
        command = package.labels[:system_first][:command]
        return false unless system_command? command
        version_condition = package.labels[:system_first][:version_condition]
        return false unless version_condition
        version = VersionSpec.new package.labels[:system_first][:version].call(command)
        eval "version #{version_condition.split.first} '#{version_condition.split.last}'"
      end
    end
  end
end
