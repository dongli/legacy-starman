module STARMAN
  class PackageSpec
    include Utils

    def initialize
      @revision = {}
      @languages = []
      @labels = {}
      @dependencies = {}
      @slaves = []
      # Common options.
      @options = {
        :'skip-test' => OptionSpec.new(
          :desc => 'Skip the build test.',
          :accept_value => { :boolean => false },
          :extra => { :profile => false },
          cascade: true
        )
      }
      @patches = []
    end

    # Data need to be cleaned between load statements.
    def clean
      @languages = []
      @labels = {}
      @dependencies = {}
      @slaves = []
      @patches = []
    end

    [:homepage, :mirror, :sha256, :version, :filename, :group_master].each do |attr|
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
        def #{attr} *values, **options
          values.flatten!
          if not values.empty?
            case @#{attr}s
            when Array
              @#{attr}s.concat values
              @#{attr}s.uniq!
            when Hash
              values.each do |value|
                @#{attr}s[value] = options
              end
            end
          end
        end

        def has_#{attr}? value
          case @#{attr}s
          when Array
            #{attr}s.include? value
          when Hash
            #{attr}s.has_key? value
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

    def path
      "#{ConfigStore.package_root}/#{filename}"
    end

    def revision val = nil, options = {}
      if val
        @revision[val] = options
      elsif @revision.empty?
        # Default revision is 0, package maintainer needs not to write revision 0.
        @revision[0] = {}
      end
      @revision
    end

    attr_reader :options, :dependencies, :slaves

    def option val, *options
      # Should not override option.
      return if @options.has_key? val.to_sym
      if options.first.class == Hash
        @options[val.to_sym] = OptionSpec.new(options.first)
      else
        @options[val.to_sym] = OptionSpec.new({
          desc: options[0],
          accept_value: options[1]
        })
      end
    end

    def depends_on val, options = {}
      @dependencies[val] = symbolize_keys options
    end

    def slave val
      @slaves << val if not @slaves.include? val
    end

    attr_reader :patches

    def patch data = nil, &block
      if data
        @patches << data
      else
        spec = PackageSpec.new
        files = []
        spec.instance_exec files, &block
        if files.empty?
          @patches << spec
        else
          @patches << [spec, files]
        end
      end
    end
  end
end
