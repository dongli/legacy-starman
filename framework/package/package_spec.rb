module STARMAN
  class PackageSpec
    [:homepage, :mirror, :sha256, :version, :filename].each do |attr|
      attr_reader attr
      class_eval <<-EOT
        def #{attr} val = nil
          @#{attr} = val if val
          @#{attr}
        end
      EOT
    end

    attr_reader :url, :options, :dependencies

    def initialize
      @options = {}
      @dependencies = {}
    end

    def url val
      @url = val
      @filename = File.basename(URI.parse(val).path) if not @filename
    end

    def option val, **options
      # Should not override option.
      @options[val] = OptionSpec.new(options) if not @options.has_key? val
    end

    def depends_on val, **options
      @dependencies[val] = options
    end
  end
end
