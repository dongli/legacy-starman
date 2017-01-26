module STARMAN
  class PackageProfile
    extend System::Command

    class << self
      def read_profile package_or_prefix_or_file
        case package_or_prefix_or_file
        when String
          prefix = package_or_prefix_or_file
          package_name = Pathname.new(package_or_prefix_or_file).dirname.dirname.basename
          profile_file = "#{prefix}/#{package_name}.profile"
        when Package
          prefix = package_or_prefix_or_file.prefix
          package_name = package_or_prefix_or_file.name
          profile_file = "#{prefix}/#{package_name}.profile"
        when File
          profile_file = package_or_prefix_or_file
        end
        File.exist?(profile_file) ? YAML.load(File.read(profile_file)) : {}
      end

      def write_profile package
        if package.has_label? :parasite
          host_package = PackageLoader.packages[package.labels[:parasite][:into]][:instance]
          profile = host_package.profile
          profile[:parasites] ||= {}
          profile[:parasites][package.name] = package.profile
          profile[:parasites][package.name][:dependencies] ||= {}
          package.dependencies.each do |depend_name, options|
            next if depend_name == package.labels[:parasite][:into]
            depend = CommandLine.packages[depend_name]
            next if Command::Install.skip? depend
            profile[:parasites][package.name][:dependencies][depend_name] = depend.profile
          end
          profile_file = "#{host_package.prefix}/#{host_package.name}.profile"
        else
          host_package = package
          profile = package.profile
          profile[:os_tag] = OS.tag
          if not package.has_label? :external_binary
            profile[:compiler_tag] = CompilerStore.active_compiler_set.tag.sub('-', '')
          end
          profile_file = "#{package.prefix}/#{package.name}.profile"
        end
        profile[:dependencies] ||= {}
        host_package.dependencies.each do |depend_name, options|
          depend = CommandLine.packages[depend_name]
          next if Command::Install.skip? depend
          profile[:dependencies][depend_name] = depend.profile
        end
        File.open(profile_file, 'w') do |file|
          file.write(profile.to_yaml)
          file.close
        end
      end
    end
  end
end
