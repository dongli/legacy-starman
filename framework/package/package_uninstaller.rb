module STARMAN
  class PackageUninstaller
    extend System::Command
    extend FileUtils

    def self.run path
      CLI.report_notice "Uninstall #{CLI.red path}."
      begin
        rm_r path
        rm_r path.dirname if path.dirname.children.empty?
        rm_r path.dirname.dirname if path.dirname.dirname.children.empty?
      rescue
      end
    end
  end
end
