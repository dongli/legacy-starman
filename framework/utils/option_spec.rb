module STARMAN
  class OptionSpec
    attr_reader :desc, :type, :default, :cascade, :extra
    attr_writer :value

    OptionTypes = [
      :package,
      :path,
      :boolean,
      :string,
      :integer
    ].freeze

    def initialize **options
      @desc = options[:desc]
      case options[:accept_value]
      when Symbol
        @type = options[:accept_value]
        @default = nil
      when Hash
        if options[:accept_value].keys.size != 1
          CLI.report_error "Only one option type is allowed, but given #{CLI.red options[:accept_value].to_s}!"
        end
        @type = options[:accept_value].keys.first
        @default = options[:accept_value].values.first
      end
      @cascade = options[:cascade] || false # Control whether the option can be transferred, e.g., from one package to another package.
      @extra = options[:extra] || {}
    end

    def check value
      case type
      when :package
        raise "Package #{CLI.red value} does not exist!" if not PackageLoader.has_package? value
      when :path
        raise "Input is empty!" if value == ''
        raise "File or directory #{CLI.red value} does not exist!" if not File.exist? value
      when :boolean
        if value.class == FalseClass or value.class == TrueClass
        elsif value == '' or value.downcase == 'true'
          value = true
        elsif value.downcase == 'false'
          value = false
        else
          raise 'Boolean value is needed!'
        end
      when :string
        raise 'String value is needed!' if value == ''
      when :integer
        begin
          value = Integer(value)
        rescue => e
          raise 'Integer value is needed!'
        end
      end
      @value = value
    end

    def value
      @value != nil ? @value : default
    end

    def inspect
      res = "#{@desc} [#{@type}: #{@default}]"
    end
  end
end
