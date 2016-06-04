module STARMAN
  module System
    class Bash
      def self.rc_file
        @@rc_file ||= "#{ConfigStore.install_root}/starman.bashrc.#{CompilerStore.active_compiler_set_index}"
      end

      def self.reset_rc_file
        @@rc_file = "#{ConfigStore.install_root}/starman.bashrc.#{CompilerStore.active_compiler_set_index}"
      end

      def self.mode
        @@mode ||= CommandLine.command == :shell ? :file : :env
      end

      def self.init
        FileUtils.touch rc_file if mode == :file
      end

      def self.final
        FileUtils.rm rc_file if mode == :file
      end

      def self.set keys, value, **options
        case mode
        when :file
          content = File.open(rc_file, 'r').read
          Array(keys).each do |key|
            if not content.gsub!(/export #{key}="([^\)"]+)"/, "export #{key}=\"#{value}\"")
              content << "export #{key}=\"#{value}\"\n"
            end
          end
          write content
        when :env
          Array(keys).map(&:to_s).each do |key|
            ENV[key] = value
          end
        end
      end

      def self.append keys, value, **options
        separator = options[:separator] || ' '
        case mode
        when :file
          content = File.open(rc_file, 'r').read
          Array(keys).each do |key|
            if not content.gsub!(/export #{key}="([^\)"]+)"/, "export #{key}=\"\\1#{separator}#{value}\"")
              if options[:system]
                content << "export #{key}=\"$#{key}#{separator}#{value}\"\n"
              else
                content << "export #{key}=\"#{value}\"\n"
              end
            end
          end
          write content
        when :env
          Array(keys).map(&:to_s).each do |key|
            if ENV[key]
              ENV[key] = "#{ENV[key]}#{separator}#{value}"
            else
              ENV[key] = value
            end
          end
        end
      end

      def self.prepend keys, value, **options
        separator = options[:separator] || ' '
        case mode
        when :file
          content = File.open(rc_file, 'r').read
          Array(keys).each do |key|
            if not content.gsub!(/export #{key}="([^\)"]+)"/, "export #{key}=\"#{value}#{separator}\\1\"")
              if options[:system]
                content << "export #{key}=\"#{value}#{separator}$#{key}\"\n"
              else
                content << "export #{key}=\"#{value}\"\n"
              end
            end
          end
          write content
        when :env
          Array(keys).map(&:to_s).each do |key|
            if ENV[key]
              ENV[key] = "#{value}#{separator}#{ENV[key]}"
            else
              ENV[key] = value
            end
          end
        end
      end

      def self.whitelist keys, **options
        separator = options[:separator] || ' '
        Array(keys).each do |key|
          next if not ENV[key]
          new_value = []
          ENV[key].split(separator).each do |value|
            next if not System::Shell.whitelists[key].include? value
            new_value << value
          end
          ENV[key] = new_value.join(separator)
        end
      end

      private

      def self.write content
        File.open(rc_file, 'w') do |f|
          f.write content
          f.flush
        end
      end
    end
  end
end
