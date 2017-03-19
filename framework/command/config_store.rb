module STARMAN
  class ConfigStore
    extend Utils
    extend FileUtils

    class << self
      def config
        @@config ||= {}
      end

      def init
        if not File.exist? CommandLine.options[:config].value
          write_template CommandLine.options[:config].value
        end
        return if CommandLine.command == :config
        begin
          @@config = YAML.load(File.read(CommandLine.options[:config].value)).to_hash
        rescue SyntaxError => e
          CLI.report_error "Failed to parse #{CLI.red CommandLine.options[:config].value}!\n#{e}"
        end
        @@config = symbolize_keys @@config
        @@config.each_key do |key|
          @@config[key] = symbolize_keys @@config[key] if @@config[key].class == Hash
          class_eval <<-EOT
            def self.#{key}
              @@config[:#{key}]
            end
          EOT
        end
      end

      def run
        return if CommandLine.command == :config
        @@config[:package_root] = File.expand_path @@config[:package_root]
        @@config[:install_root] = File.expand_path @@config[:install_root]
        mkdir_p @@config[:package_root] if not Dir.exist? @@config[:package_root]
        mkdir_p @@config[:install_root] if not Dir.exist? @@config[:install_root]
        if @@config[:defaults][:command_line_options]
          ARGV.concat @@config[:defaults][:command_line_options].split || []
          CommandLine.run
        end
        set_compilers
      end

      def set_compilers
        command_hash_array = []
        ( @@config.keys.select { |m| m.to_s =~ /compiler_set_\d$/ } ).each do |m|
          command_hash = self.method(m).call
          if command_hash != nil
            if command_hash.has_key? :installed_by_starman
              command_hash[:installed_by_starman].downcase!
            end
            command_hash_array << command_hash
          end
        end
        if command_hash_array.empty?
          CLI.report_warning "There is no compiler set defined in #{CommandLine.options[:config].value}!"
        else
          CompilerStore.set_compiler_sets command_hash_array
          CompilerStore.set_active_compiler_set @@config[:defaults][:compiler_set_index]
        end
      end

      def write_template file_path
        if OS.mac?
          default_compilers = {
            'c' => '/usr/bin/clang',
            'cxx' => '/usr/bin/clang++'
          }
        else
          default_compilers = {
            'c' => '/usr/bin/gcc',
            'cxx' => '/usr/bin/g++',
            'fortran' => '/usr/bin/gfortran'
          }
        end
        template = {
          'package_root' => '/opt/starman/packages',
          'install_root' => '/opt/starman/software',
          'defaults' => {
            'shell' => 'bash',
            'download_command' => 'curl',
            'compiler_set_index' => 0,
            'mpi' => 'mpich'
          },
          'compiler_set_0' => default_compilers
        }
        write_file file_path, template.to_yaml
      end

      def write_config file_path = nil
        file_path ||= CommandLine.options[:config].value
        # Users may not be familiar with symbol in Ruby, so we convert them into
        # strings.
        @@config = stringfy_keys @@config
        @@config.each_key do |key|
          @@config[key] = stringfy_keys @@config[key] if @@config[key].class == Hash
        end
        write_file file_path, @@config.to_yaml
      end
    end
  end
end
