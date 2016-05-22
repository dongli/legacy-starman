module STARMAN
  class PackageSpec
    def initialize
      @revision = {}
      @languages = []
      @labels = {}
      @options = {}
      @dependencies = {}
    end

    # Data need to be cleaned between load statements.
    def clean
      @languages = []
      @dependencies = {}
    end

    [:homepage, :mirror, :sha256, :version, :filename].each do |attr|
      class_eval <<-EOT
        def #{attr} val = nil
          @#{attr} = val if val
          @#{attr}
        end
      EOT
    end

    [:label, :language].each do |attr|
      class_eval <<-EOT
        attr_reader :#{attr}s
        def #{attr} *val, **options
          val.flatten!
          if not val.empty?
            @#{attr}s.concat val
            @#{attr}s.uniq!
          end
        end
      EOT
    end

    def url val = nil
      if val
        @url = val
        @filename = File.basename(URI.parse(val).path) if not @filename
      end
      @url
    end

    def revision val = nil, **options
      if val
        @revision[val] = options
      elsif @revision.empty?
        # Default revision is 0, package maintainer needs not to write revision 0.
        @revision[0] = {}
      end
      @revision
    end

    attr_reader :options, :dependencies

    def option val, **options
      # Should not override option.
      @options[val.to_sym] = OptionSpec.new(options) if not @options.has_key? val.to_sym
    end

    def depends_on val, **options
      @dependencies[val] = options
    end
  end
end
