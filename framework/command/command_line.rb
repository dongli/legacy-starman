module STARMAN
  class CommandLine
    CommonOptions = {
      debug: OptionSpec.new(
        desc: 'Turn on debug stuffs, may output more information.',
        accept_value: { boolean: false }
      ),
      verbose: OptionSpec.new(
        desc: 'Show more outputs, such as command run output.',
        accept_value: { boolean: false }
      ),
      config: OptionSpec.new(
        desc: 'Configuration file.',
        accept_value: { path: "#{ENV['STARMAN_ROOT']}/starman.config" }
      ),
      :'make-jobs' => OptionSpec.new(
        desc: 'Make job number.',
        accept_value: { integer: 1 }
      )
    }

    def self.run
      @@options ||= {}
      ARGV.each do |arg|
        if not defined? @@command and Command.constants.include? arg.capitalize.to_sym
          @@command = arg.to_sym
        elsif @@command
          if arg =~ /^-/
            option = arg.gsub(/(^-)|(=.*$)/, '').to_sym
            value = arg.gsub(/^-[^=]+/, '').delete('=')
            @@options[option] = value
          elsif PackageLoader.has_package? arg
            @@packages ||= {}
            @@packages[arg.to_sym] = nil
          end
        end
      end
      if not defined? @@command
        CLI.report_error "You haven't specify command!"
      end
      check_command_options
    end

    def self.check_command_options
      options.each do |name, value|
        option_spec = nil
        option_spec ||= eval("Command::#{@@command.capitalize.to_sym}").accepted_options[name]
        option_spec ||= CommonOptions[name]
        next if not option_spec
        CLI.report_error "Option #{CLI.red name} is invalid!" if not option_spec
        begin
          option_spec.check value
        rescue => e
          CLI.report_error "Command option #{CLI.red name}: #{e}"
        end
        options[name] = option_spec
      end
      @@options = eval("Command::#{@@command.capitalize.to_sym}").accepted_options.merge(@@options)
      @@options = CommonOptions.merge(@@options)
    end

    def self.check_invalid_options
      @@options.each do |name, value|
        next if value.class == OptionSpec or not value.empty?
        CLI.report_error "Unknown option #{CLI.red name}!"
      end
      if [:install, :remove].include? @@command
        CLI.report_error "No valid package to operate on!" if @@packages.empty?
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
      @@packages ||= {}
    end
  end
end
