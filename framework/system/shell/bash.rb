module STARMAN
  module System
    class Bash
      def self.shell_board_file
        @@shell_board_file ||= "#{ENV['STARMAN_ROOT']}/.starman.bash.#{Process.pid}"
      end

      def self.init
        FileUtils.touch shell_board_file
      end

      def self.final
        return if not File.exist? shell_board_file
        FileUtils.rm shell_board_file
      end

      def self.set keys, value, **options
        content = File.open(shell_board_file, 'r').read
        Array(keys).each do |key|
          if not content.gsub!(/export #{key}="([^\)"]+)"/, "export #{key}=\"#{value}\"")
            content << "export #{key}=\"#{value}\"\n"
          end
        end
        write content
      end

      def self.append keys, value, **options
        content = File.open(shell_board_file, 'r').read
        separator = options[:separator] || ' '
        Array(keys).each do |key|
          if not content.gsub!(/export #{key}="([^\)"]+)"/, "export #{key}=\"\1#{separator}#{value}\"")
            content << "export #{key}=\"#{value}\"\n"
          end
        end
        write content
      end

      private

      def self.write content
        File.open(shell_board_file, 'w') do |f|
          f.write content
          f.flush
        end
      end
    end
  end
end
