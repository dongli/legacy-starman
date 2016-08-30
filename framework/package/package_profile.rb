module STARMAN
  class PackageProfile
    extend System::Command

    class << self
      def read_profile package_or_prefix
        if package_or_prefix.class == String
          prefix = package_or_prefix
          package_name = Pathname.new(package_or_prefix).dirname.dirname.basename
        else
          prefix = package_or_prefix.prefix
          package_name = package_or_prefix.name
        end
        profile_file = "#{prefix}/#{package_name}.profile"
        File.exist?(profile_file) ? YAML.load(File.read(profile_file)) : {}
      end

      def write_profile package
        profile = package.profile
        profile[:os_tag] = OS.tag
        if not package.has_label? :external_binary
          profile[:compiler_tag] = CompilerStore.active_compiler_set.tag.sub('-', '')
        end
        package.dependencies.each do |depend_name, options|
          depend = CommandLine.packages[depend_name]
          profile[:dependencies] ||= {}
          profile[:dependencies][depend_name] = depend.profile
        end
        profile_file = "#{package.prefix}/#{package.name}.profile"
        File.open(profile_file, 'w') do |file|
          file.write(profile.to_yaml)
          file.close
        end
      end
    end
  end
end
