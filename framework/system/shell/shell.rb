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

        [:rc_file, :reset_rc_file, :final].each do |action|
          class_eval <<-EOT
            def #{action}
              @@shell.#{action} if defined? @@shell
            end
          EOT
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
