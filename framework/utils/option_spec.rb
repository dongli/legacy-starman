module STARMAN
  class OptionSpec
    attr_reader :desc, :type, :default, :extra
    attr_writer :value

    OptionTypes = [
      :package,
      :path,
      :boolean,
      :string
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
        if value == '' or value.downcase == 'true'
          value = true
        elsif value.downcase == 'false'
          value = false
        else
          raise 'Boolean value is needed!'
        end
      when :string
        raise 'String value is needed!' if value == ''
      end
      @value = value
    end

    def value
      @value != nil ? @value : default
    end
  end
end
