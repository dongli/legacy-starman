module STARMAN
  class PackageDownloader
    extend System::Command
    extend Utils

    def self.run package
      download_command = ConfigStore.config[:defaults][:download_command]
      # Check if there is any resource to download.
      if not package.resources.empty?
        package.resources.each do |tag, resource|
          file_path = "#{ConfigStore.package_root}/#{resource.filename}"
          if not ( File.exist? file_path and sha_same? file_path, resource.sha256 )
            CLI.report_notice "Downloading resource #{CLI.blue tag}."
            send download_command, resource.url, ConfigStore.package_root, rename: resource.filename
          end
        end
      end
      # Check if there is any patch to download.
      if not package.patches.empty?
        package.patches.each_with_index do |patch, index|
          case patch
          when PackageSpec
            # Change patch filename.
            patch.filename "#{package.name}.patch.#{index}"
            file_path = "#{ConfigStore.package_root}/#{patch.filename}"
            if not ( File.exist? file_path and sha_same? file_path, patch.sha256 )
              CLI.report_notice "Downloading patch #{CLI.blue index}."
              send download_command, patch.url, ConfigStore.package_root, rename: patch.filename
            end
          when Array
            file_path = "#{ConfigStore.package_root}/#{patch.first.filename}"
            if not ( File.exist? file_path and sha_same? file_path, patch.first.sha256 )
              CLI.report_notice "Downloading patch #{CLI.blue patch.first.filename}."
              send download_command, patch.first.url, ConfigStore.package_root, rename: patch.first.filename
            end
          end
        end
      end
      # Check if install_root matches preset one.
      # Check if there is a precompiled binary first.
      if not (CommandLine.options[:'local-build'] and CommandLine.options[:'local-build'].value) and
         ConfigStore.install_root == '/opt/starman/software'
        _package = package.group_master || package
        if PackageBinary.has? _package
          if not PackageBinary.match? _package
            CLI.report_notice "Downloading precompiled package #{CLI.blue _package.name}."
            Storage.download _package
          end
          return :binary
        end
      end
      if package.has_label? :external_binary
        file_path = "#{ConfigStore.package_root}/#{package.external_binary.filename}"
        if not ( File.exist? file_path and sha_same? file_path, package.external_binary.sha256 )
          CLI.report_notice "Downloading package #{CLI.blue package.name}."
          send download_command, package.external_binary.url, ConfigStore.package_root, rename: package.external_binary.filename
        end
        return :binary
      elsif package.url
        # Package is not compiled before.
        file_path = "#{ConfigStore.package_root}/#{package.filename}"
        if not ( File.exist? file_path and sha_same? file_path, package.sha256 )
          CLI.report_notice "Downloading package #{CLI.blue package.name}."
          send download_command, package.url, ConfigStore.package_root, rename: package.filename
        end
        return :source
      end
    end
  end
end
