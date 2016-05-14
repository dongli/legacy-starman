module STARMAN
  class PackageSpec
    [:homepage, :url, :mirror, :sha256, :version].each do |attr|
      attr_reader attr
      class_eval <<-EOT
        def #{attr} val = nil
          @#{attr} = val if val
          @#{attr}
        end
      EOT
    end

    attr_reader :options, :dependencies

    def initialize
      @options = {}
      @dependencies = {}
    end

    def option val, **options
      # Should not override option.
      @options[val] = options if not @options.has_key? val
    end

    def depends_on val, **options
      @dependencies[val] = options
    end
  end
end
