module STARMAN
  class CommandLine
    def self.run
      ARGV.each do |arg|
        if not defined? @@command and Command.constants.include? arg.capitalize.to_sym
          @@command = arg
        elsif @@command
          if arg =~ /^-/
            option = arg.gsub(/(^-)|(=.*$)/, '').to_sym
            value = arg.gsub(/^-[^=]+/, '').gsub('=', '')
            @@options ||= {}
            @@options[option] = value
          elsif PackageLoader.has_package? arg
            @@packages ||= []
            @@packages << arg.to_sym
          end
        end
      end
      if not defined? @@command
        CLI.report_error "You haven't specify command!"
      end
    end

    def self.check_options
      options.each do |option, value|
        option_spec = nil
        packages.each do |package|
          option_spec = PackageLoader.packages[package][:instance].options[option]
          break if option_spec
        end
        option_spec = eval("Command::#{@@command.capitalize.to_sym}").accepted_options[option] if not option_spec
        CLI.report_error "Option #{CLI.red option} is invalid!" if not option_spec
        CLI.report_error "Option #{CLI.red option} does not accept value!" if value != '' and not option_spec[:accept_value]
        CLI.report_error "Option #{CLI.red option} needs value!" if value == '' and option_spec[:accept_value] and not option_spec[:accept_value].has_key? :boolean
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
