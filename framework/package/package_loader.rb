module STARMAN
  class PackageLoader
    @@packages = {}
    Dir.glob("#{ENV['STARMAN_ROOT']}/packages/*.rb").each do |file|
      name = File.basename(file, '.rb').to_sym
      @@packages[name] = { :file => file }
    end

    def self.transfer_command_line_options_to package
      # Check command line options for package options.
      CommandLine.options.each do |name, value|
        next unless package.options.has_key? name
        begin
          package.options[name].check value
        rescue => e
          CLI.report_error "Package option #{CLI.red name}: #{e}"
        end
      end
    end

    def self.load_package name, options = {}
      return if packages[name][:instance]
      load packages[name][:file]
      package = eval("#{name.to_s.capitalize}").new
      transfer_command_line_options_to package
      # Reload package, since the options may change dependencies.
      load packages[name][:file]
      package = eval("#{name.to_s.capitalize}").new
      CommandLine.packages[name] = package # Record the package to install.
      packages[name][:instance] = package
      package.dependencies.each do |depend_name, options|
        load_package depend_name, options
      end
    end

    def self.run
      CommandLine.packages.keys.each do |name|
        load_package name.to_s.downcase.to_sym
      end
    end

    def self.has_package? name
      @@packages.has_key? name.to_s.downcase.to_sym
    end

    def self.packages
      @@packages
    end
  end
end
