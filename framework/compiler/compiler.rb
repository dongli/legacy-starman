module STARMAN
  class Compiler
    include CompilerDSL

    extend Forwardable
    def_delegators :spec, :vendor, :languages, :flags, :feature?

    attr_reader :spec

    def initialize active_language
      @active_language = active_language
      @spec = eval "@@#{self.class.name.split('::').last.downcase.to_sym}_spec.clone"
    end

    def version language = nil
      @spec.version language || @active_language
    end

    def tag language
      "#{File.basename languages[language][:command]}_#{version(language).major_minor}"
    end

    [:command, :default_flags].each do |attr|
      class_eval <<-EOT
        def #{attr}
          @spec.languages[@active_language][:#{attr}]
        end
      EOT
    end

    class << self
      def choose_spec language, command
        @@compiler_classes ||= []
        if @@compiler_classes.empty?
          STARMAN.constants.each do |c|
            @@compiler_classes << c if c.to_s =~ /\wCompiler/
          end
        end
        @@compiler_classes.each do |compiler_class|
          spec = eval "#{compiler_class}.new :#{language}"
          next if not spec.languages.keys.include? language
          Array(spec.languages[language][:command]).each do |spec_command|
            if File.basename(command) == spec_command
              spec.languages[language][:command] = Pathname.new command
              return spec
            end
          end
        end
        CLI.report_error "Unknown compiler #{CLI.red command}!"
      end

      def compiler_name
        self.name.split('::').last.downcase.to_sym
      end
    end
  end
end
