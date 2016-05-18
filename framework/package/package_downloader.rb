module STARMAN
  class PackageDownloader
    extend System::Command

    def self.sha256_same? file_path, expect
      if File.file? file_path
        expect.eql? Digest::SHA256.hexdigest(File.read(file_path))
      elsif File.directory? file_path
        tmp = []
        Dir.glob("#{file_path}/**/*").each do |file|
          next if File.directory? file
          tmp << Digest::SHA256.hexdigest(File.read(file))
        end
        current = Digest::SHA256.hexdigest(tmp.sort.join)
        if expect.eql? current
          return true
        else
          CLI.report_warning "Directory #{file_path} SHA256 is #{current}."
          return false
        end
      else
        CLI.report_error "Unknown file type \"#{file_path}\"!"
      end
    end

    def self.run package
      file_path = "#{ConfigStore.package_root}/#{package.filename}"
      if not ( File.exist? file_path and sha256_same? file_path, package.sha256 )
        CLI.report_notice "Downloading package #{CLI.blue package.name}."
        curl package.url, ConfigStore.package_root, rename: package.filename
      end
    end
  end
end
