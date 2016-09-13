module STARMAN
  module PackageResource
    def self.included base
      base.extend self
    end

    def install_resource tag, dir, **options
      FileUtils.mkdir_p dir if not Dir.exist? dir
      if options.include? :plain_file
        FileUtils.cp "#{ConfigStore.package_root}/#{resource(tag).filename}", dir
      else
        work_in dir do
          decompress "#{ConfigStore.package_root}/#{resource(tag).filename}", **options
        end
      end
    end
  end
end
