module STARMAN
  class ConfigStore
    PermittedKeys = %W[
      package_root
      install_root
      defaults
      download_command
      compiler_set_0
      compiler_set_1
      compiler_set_2
      compiler_set_3
      compiler_set_4
    ].freeze

    def self.init
      PermittedKeys.each do |key|
        class_eval "@@#{key} = nil"
        class_eval "def self.#{key}=(value); @@#{key} = value; end"
        class_eval "def self.#{key}; @@#{key}; end"
      end
      # Set default values.
      @@download_command = :curl
      @@defaults = {}
    end

    def self.run
      return if CommandLine.command == :config
      if not File.exist? CommandLine.options[:config].value
        template CommandLine.options[:config].value
      end
      content = File.open(CommandLine.options[:config].value, 'r').read
      # Modify the config to fulfill the needs of Ruby.
      PermittedKeys.each do |key|
        content.gsub!(/^ *#{key} *=/, "self.#{key}=")
      end
      begin
        class_eval content
      rescue SyntaxError => e
        CLI.report_error "Failed to parse #{CLI.red CommandLine.options[:config].value}!\n#{e}"
      end
      @@package_root = File.expand_path @@package_root
      @@install_root = File.expand_path @@install_root
      FileUtils.mkdir_p @@package_root if not Dir.exist? @@package_root
      FileUtils.mkdir_p @@install_root if not Dir.exist? @@install_root
      @@download_command = @@download_command.to_sym
      set_compilers
    end

    def self.set_compilers
      command_hash_array = []
      ( self.methods.select { |m| m.to_s =~ /compiler_set_\d$/ } ).each do |m|
        command_hash = self.method(m).call
        if command_hash != nil
          if command_hash.has_key? :installed_by_starman
            command_hash[:installed_by_starman].downcase!
          end
          command_hash_array << command_hash
        end
      end
      if command_hash_array.empty?
        CLI.report_error "There is no compiler set defined in #{CommandLine.config_file}!"
      end
      CompilerStore.set_compiler_sets command_hash_array
      CompilerStore.set_active_compiler_set @@defaults[:compiler_set_index]
    end

    def self.template file_path
      File.open(file_path, 'w') do |file|
        file << <<-EOT.keep_indent
          package_root = '/opt/starman/packages'
          install_root = '/opt/starman/software'
          download_command = 'curl'
          defaults = {
            :compiler_set_index => 0,
            :mpi => 'mpich'
          }
          compiler_set_0 = {
          }
        EOT
      end
    end
  end
end
