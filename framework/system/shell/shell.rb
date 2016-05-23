module STARMAN
  module System
    class Shell
      class << self
        def init
          return if CommandLine.command == :config
          eval "@@shell = #{ConfigStore.defaults[:shell].to_s.capitalize}"
          @@shell.init
        end

        [:shell_board_file, :final].each do |action|
          class_eval <<-EOT
            def #{action}
              @@shell.#{action}
            end
          EOT
        end

        [:set, :append].each do |action|
          class_eval <<-EOT
            def #{action} keys, value, **options
              @@shell.#{action} keys, value, **options
            end
          EOT
        end
      end
    end
  end
end
