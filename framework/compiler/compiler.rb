module STARMAN
  class Compiler
    include CompilerDSL

    extend Forwardable
    def_delegators :spec, :vendor, :version, :languages, :flags, :feature?

    attr_reader :spec

    def initialize
      @spec = eval "@@#{self.class.name.split('::').last.downcase.to_sym}_spec"
    end

    def tag language
      "#{File.basename languages[language][:command]}_#{version.major_minor}"
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
          spec = eval "#{compiler_class}.new"
          return nil if not spec.languages.keys.include? language
          Array(spec.languages[language][:command]).each do |spec_command|
            if File.basename(command) == spec_command
              spec.languages[language][:command] = command
              return spec.clone
            end
          end
        end
      end

      def compiler_name
        self.name.split('::').last.downcase.to_sym
      end
    end
  end
end
