module STARMAN
  module System
    class Xcode
      extend Command

      def self.init
        @@origin_dev_dir = `xcode-select -p`
        @@dev_dir_changed = false
      end

      def self.command_line_tools?
        `xcode-select -p`.chomp == '/Library/Developer/CommandLineTools'
      end

      def self.select dev_dir
        res = `xcode-select -p`
        if dev_dir == :xcode_app and res != '/Applications/Xcode.app/Contents/Developer'
          @@dev_dir_changed = true
          run 'sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer'
        elsif dev_dir == :command_line_tools and res != '/Library/Developer/CommandLineTools'
          @@dev_dir_changed = true
          run 'sudo xcode-select --switch /Library/Developer/CommandLineTools'
        end
      end

      def self.final
        run "sudo xcode-select --switch #{@@origin_dev_dir}" if @@dev_dir_changed
      end
    end
  end
end
