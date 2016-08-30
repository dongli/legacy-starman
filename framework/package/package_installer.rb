module STARMAN
  class PackageInstaller
    extend System::Command

    class << self
      def installed? package
        profile = PackageProfile.read_profile package
        if package.has_label? :external_binary
          profile[:sha256] == package.external_binary.sha256
        else
          profile[:sha256] == package.sha256
        end
      end

      def run package
        return false if installed? package
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
              PackageProfile.write_profile package
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
