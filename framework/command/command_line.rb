module STARMAN
  class CommandLine
    def self.parse
      ARGV.each do |arg|
        if not defined? @@command and Command.constants.include? arg.capitalize.to_sym
          @@command = arg
        elsif @@command
          if arg =~ /^--/
            option = arg.gsub(/(^--)|(=.*$)/, '').to_sym
            value = arg.gsub(/^--[^=]+/, '').gsub('=', '')
            option_info = eval("Command::#{@@command.capitalize.to_sym}").accepted_options[option]
            CLI.report_error "Option #{CLI.red option} is invalid!" if not option_info
            CLI.report_error "Option #{CLI.red option} does not accept value!" if value != '' and not option_info[:accept_value]
            CLI.report_error "Option #{CLI.red option} needs value!" if value == '' and option_info[:accept_value]
            @@options ||= {}
            @@options[option] = value
          elsif PackageLoader.has_package? arg
            @@packages ||= []
            @@packages << arg
          end
        end
      end
      if not defined? @@command
        CLI.report_error "You haven't specify command!"
      end
    end

    def self.command
      @@command ||= nil
    end

    def self.options
      @@options ||= {}
    end

    def self.has_option? option
      options.has_key? option
    end

    def self.packages
      @@packages ||= []
    end
  end
end
