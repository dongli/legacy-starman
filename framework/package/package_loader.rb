module STARMAN
  class PackageLoader
    @@packages = {}
    Dir.glob("#{ENV['STARMAN_ROOT']}/packages/*.rb").each do |file|
      name = File.basename(file, '.rb').to_sym
      @@packages[name] = { :file => file }
    end

    def self.transfer_profile_to package, profile
      package.version profile[:version]
      package.sha256 profile[:sha256]
      transfer_options_to package, profile[:options]
    end

    def self.transfer_options_to package, options
      options.each do |name, value|
        next unless package.options.has_key? name
        begin
          if value.class == OptionSpec
            package.options[name] = value if value.cascade
          else
            package.options[name].check value
            CommandLine.options[name] = package.options[name]
          end
        rescue => e
          CLI.report_error "Package option #{CLI.red name}: #{e}"
        end
      end
      CommandLine.check_invalid_options
    end

    def self.load_package name, options = {}
      return if (not packages.has_key? name or packages[name][:instance]) and not options[:force]
      Package.clean name
      load packages[name][:file]
      package = eval("#{name.to_s.capitalize}").new
      transfer_options_to package, CommandLine.options
      transfer_options_to package, options
      # Reload package, since the options may change dependencies.
      Package.clean name
      load packages[name][:file]
      package = eval("#{name.to_s.capitalize}").new
      # Connect group master and slave.
      if package.group_master
        load_package package.group_master, options
        package.group_master packages[package.group_master][:instance]
        package.group_master.slave package
      end
      packages[name][:instance] = package
      package.dependencies.each do |depend_name, options|
        # TODO: Change package.dependencies.
        depend_name = PackageAlias.lookup depend_name if not packages.has_key? depend_name
        load_package depend_name, options
      end
      # Remove skipped dependencies.
      package.dependencies.delete_if do |depend_name, options|
        depend = packages[depend_name][:instance]
        Command::Install.skip? depend
      end
      @@package_string << package.name unless Command::Install.skip? package
    end

    def self.run
      return if CommandLine.command == :edit
      @@package_string = []
      CommandLine.packages.keys.each do |name|
        load_package name.to_s.downcase.to_sym
      end
      CommandLine.packages = {}
      @@package_string.each do |name|
        CommandLine.packages[name] = packages[name][:instance]
      end
    end

    def self.has_package? name
      @@packages.has_key? name.to_s.downcase.to_sym
    end

    def self.packages
      @@packages
    end

    def self.scan_installed_package package_name, options = {}
      dir = "#{ConfigStore.install_root}/#{package_name}"
      return unless File.directory? dir and packages.has_key? package_name
      load_package package_name
      package = packages[package_name][:instance]
      profiles = []
      Dir.glob("#{dir}/*/*").each do |prefix|
        next if Pathname.new(prefix).dirname.basename.to_s == 'persist'
        profile = PackageProfile.read_profile prefix
        next if not package.has_label? :compiler and not package.has_label? :compiler_agnostic and
                profile[:compiler_tag] != CompilerStore.active_compiler_set.tag.gsub(/^-/, '')
        profile[:prefix] = prefix
        profiles << profile
      end
      # Filter profiles.
      profiles.delete_if { |profile| profile[:os_tag] != OS.tag }
      profiles.delete_if { |profile| profile[:compiler_tag] != CompilerStore.active_compiler_set.tag.gsub(/^-/, '') } unless package.has_label? :compiler or package.has_label? :compiler_agnostic or package.has_label? :external_binary
      return if profiles.empty?
      if profiles.size > 1
        CLI.report_warning "There are multiple installation versions of package #{CLI.blue package_name}."
        all_options = []
        profiles.each do |profile|
          option = []
          option << profile[:version]
          option << profile[:options] if profile[:options]
          option << profile[:os_tag] if profile[:os_tag]
          option << profile[:compiler_tag] if profile[:compiler_tag]
          option << profile[:prefix]
          all_options << option.join(', ')
        end
        CLI.ask 'Which one do you want to use?', all_options
        i = CLI.get_answer.to_i
      else
        i = 0
      end
      transfer_profile_to package, profiles[i]
      package
    end

    def self.installed_packages options = {}
      return @@installed_packages if defined? @@installed_packages
      @@installed_packages ||= {}
      Dir.glob("#{ConfigStore.install_root}/*").each do |dir|
        package = scan_installed_package File.basename(dir).to_sym, options
        next unless package
        @@installed_packages[package.name] = package
        if package.has_label? :group_master
          package.slaves.each do |slave|
            @@installed_packages[slave.name] = slave
          end
        end
      end
      @@installed_packages
    end
  end
end
