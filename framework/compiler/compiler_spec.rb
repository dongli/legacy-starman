module STARMAN
  class CompilerSpec
    [:vendor].each do |attr|
      class_eval <<-EOT
        def #{attr} val = nil, &block
          if block_given?
            @#{attr} = block.call
          else
            @#{attr} = val if val
          end
          @#{attr}
        end
      EOT
    end

    attr_reader :languages, :flags, :features

    def initialize
      @languages = {}
      @flags = {}
      @features = {}
    end

    def version val = nil, &block
      if block_given?
        @version = VersionSpec.new block.call
      else
        @version = VersionSpec.new val if val
      end
      @version
    end

    def language val, **options
      @languages[val] = options if val
    end

    def flag val
      @flags = val.merge(@flags)
    end

    def feature val, &block
      if block_given?
        @features[val.to_sym] = block.call
      else
        @features[val.to_sym] = true
      end
    end
  end
end
