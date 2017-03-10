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
          ),
          continue: OptionSpec.new(
            desc: 'Continue install procedures.',
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
          if not installed? package
            type = PackageDownloader.run package
            package.pre_install
            case type
            when :binary
              PackageBinary.run package
            when :source
              PackageInstaller.run package
            end
            package.post_install
            if package.has_label? :compiler
              # Handle compiler package.
              new_compiler_set_index = :"compiler_set_#{CompilerStore.compiler_sets.size}"
              ConfigStore.config[new_compiler_set_index] = {}
              package.shipped_compilers.each do |language, command|
                ConfigStore.config[new_compiler_set_index][language] = "#{package.bin}/#{command}"
              end
              ConfigStore.write_config
            end
          elsif CommandLine.options[:post].value
            package.post_install
          end
          # Set environment variables for later packages that depend on it.
          System::Shell.prepend 'PATH', package.bin, separator: ':' if Dir.exist? package.bin
          System::Shell.prepend OS.ld_library_path, package.lib, separator: ':' if Dir.exist? package.lib and not package.has_label? :system_conflict
          System::Shell.prepend 'PKG_CONFIG_PATH', package.pkg_config, separator: ':' if Dir.exist? package.pkg_config
          System::Shell.append 'CPPFLAGS', "-I#{package.inc}" if Dir.exist? package.inc
          System::Shell.append 'LDFLAGS', "-L#{package.lib}" if Dir.exist? package.lib
        end
      end

      private

      def self.skip? package
        return false if not package.has_label? :system_first or CommandLine.option(:force)
        command = package.labels[:system_first][:command]
        return false unless system_command? command and not `which #{command}`.include? package.bin
        version_condition = package.labels[:system_first][:version_condition]
        return true unless version_condition
        version = VersionSpec.new package.labels[:system_first][:version].call(command)
        eval "version #{version_condition.split.first} '#{version_condition.split.last}'"
      end

      def self.installed? package
        if package.has_label? :parasite
          profile = PackageProfile.read_profile PackageLoader.packages[package.labels[:parasite][:into]][:instance]
          sha256 = profile.fetch(:parasites, {}).fetch(package.name, {}).fetch(:sha256, nil)
        else
          profile = PackageProfile.read_profile package
          sha256 = profile[:sha256]
        end
        if package.has_label? :external_binary
          sha256 == package.external_binary.sha256
        elsif package.sha256
          sha256 == package.sha256
        elsif profile and package.has_label? :group_master
          true
        end
      end
    end
  end
end
