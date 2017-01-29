module STARMAN
  class PackageInstaller
    extend System::Command
    extend FileUtils

    class << self
      def run package
        CLI.report_notice "Install package #{CLI.blue package.name}."
        dir = "#{ConfigStore.package_root}/#{package.name}"
        mkdir dir, force: true unless CommandLine.options[:continue].value
        work_in dir do
          decompress "#{ConfigStore.package_root}/#{package.filename}" unless CommandLine.options[:continue].value
          subdirs = Dir.glob('*')
          if subdirs.size > 1
            working_dir = dir
            CLI.report_warning "There are multiple directories in #{CLI.red dir}."
          else
            working_dir = subdirs.first
          end
          work_in working_dir do
            package.patches.each_with_index do |patch, index|
              case patch
              when String
                CLI.report_notice "Apply patch #{CLI.green "##{index}"} to #{CLI.blue package.name}."
                patch_data patch
              when PackageSpec
                CLI.report_notice "Apply patch #{CLI.green "##{index}"} to #{CLI.blue package.name}."
                patch_file "#{ConfigStore.package_root}/#{package.name}.patch.#{index}"
              when Array
                mkdir 'starman.patch' do
                  decompress "#{ConfigStore.package_root}/#{patch.first.filename}"
                end
                patch_dir = Dir.glob('starman.patch/*')[0]
                patch.last.each do |file|
                  CLI.report_notice "Apply patch #{CLI.green file} to #{CLI.blue package.name}"
                  patch_file "#{patch_dir}/#{file}"
                end
              end
            end
            package.install
            PackageProfile.write_profile package
          end
        end
        rm_r dir
      end
    end
  end
end
