module STARMAN
  module System
    class Shell
      class << self
        def init
          @@whitelists = {
            'PATH' => [
              '/bin',
              '/usr/bin',
              '/usr/local/bin',
              '/usr/sbin',
              '/sbin',
              '/opt/X11/bin'
            ],
            'PKG_CONFIG_PATH' => [],
            OS.ld_library_path => []
          }.freeze
          return if CommandLine.command == :config
          eval "@@shell = #{ConfigStore.defaults[:shell].to_s.capitalize}"
          @@shell.init
        end

        [:rc_file, :reset_rc_file].each do |action|
          class_eval <<-EOT
            def #{action}
              @@shell.#{action} if defined? @@shell
            end
          EOT
        end

        def mode= val
          @@shell.mode = val
        end

        [:set, :append, :prepend].each do |action|
          class_eval <<-EOT
            def #{action} keys, value, **options
              @@shell.#{action} keys, value, **options
            end
          EOT
        end

        [:whitelist].each do |action|
          class_eval <<-EOT
            def #{action} keys, **options
              @@shell.#{action} keys, **options
            end
          EOT
        end

        [:default_environment_variables].each do |action|
          class_eval <<-EOT
            def #{action}
              @@shell.#{action}
            end
          EOT
        end

        def append_source_file file_path
          @@source_files ||= []
          @@source_files << file_path
        end

        def clean_source_files
          @@source_files = []
        end

        def source_files
          @@source_files ||= []
        end

        def shell_command
          ConfigStore.defaults[:shell]
        end

        def whitelists
          @@whitelists ||= {}
        end
      end
    end
  end
end
