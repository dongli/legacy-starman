module STARMAN
  class PackageInstaller
    extend System::Command

    class << self
      def read_profile package_or_prefix
        if package_or_prefix.class == String
          prefix = package_or_prefix
          package_name = Pathname.new(package_or_prefix).dirname.dirname.basename
        else
          prefix = package_or_prefix.prefix
          package_name = package.name
        end
        profile_file = "#{prefix}/#{package_name}.profile"
        File.exist?(profile_file) ? YAML.load(File.read(profile_file)) : {}
      end

      def write_profile package
        profile = package.profile
        profile[:os_tag] = OS.tag
        profile[:compiler_tag] = CompilerStore.active_compiler_set.tag.sub('-', '')
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

      def installed? package
        profile = read_profile package
        profile[:sha256] == package.sha256
      end

      def run package
        return if installed? package
        CLI.report_notice "Install package #{CLI.blue package.name}."
        dir = "#{ConfigStore.package_root}/#{package.name}"
        FileUtils.mkdir dir, :force => true
        work_in dir do
          decompress "#{ConfigStore.package_root}/#{package.filename}"
          subdirs = Dir.glob('*')
          if subdirs.size == 1
            work_in subdirs[0] do
              if package.patch
                CLI.report_notice "Apply patch to #{CLI.blue package.name}."
                patch package.patch
              end
              package.pre_install
              package.install
              package.post_install
              write_profile package
            end
          else
            CLI.report_error "There are multiple directories in #{CLI.red dir}."
          end
        end
        FileUtils.rm_r dir
      end
    end
  end
end
