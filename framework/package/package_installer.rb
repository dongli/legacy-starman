module STARMAN
  class PackageInstaller
    extend System::Command

    class << self
      def read_profile package
        profile_file = "#{package.prefix}/starman.profile"
        File.exist?(profile_file) ? YAML.load(File.open(profile_file, 'r').read) : {}
      end

      def write_profile package
        profile = package.profile
        package.dependencies.each do |depend_name, options|
          depend = CommandLine.packages[depend_name]
          profile[:dependencies] ||= {}
          profile[:dependencies][depend_name] = depend.profile
        end
        profile_file = "#{package.prefix}/starman.profile"
        File.new(profile_file, 'w').write profile.to_yaml
      end

      def installed? package
        profile = read_profile package
        profile[:sha256] == package.sha256
      end

      def run package
        if installed? package
          CLI.report_notice "Package #{CLI.blue package.name} has been installed."
          return
        end
        CLI.report_notice "Install package #{CLI.blue package.name}."
        dir = "#{ConfigStore.package_root}/#{package.name}"
        FileUtils.mkdir dir, :force => true
        work_in dir do
          decompress "#{ConfigStore.package_root}/#{package.filename}"
          subdirs = Dir.glob('*')
          if subdirs.size == 1
            work_in subdirs[0] do
              package.pre_install
              package.install
              package.post_install
              write_profile package
            end
          else
            CLI.report_error "There are multiple directories in #{CLI.red dir}."
          end
        end
      end
    end
  end
end
