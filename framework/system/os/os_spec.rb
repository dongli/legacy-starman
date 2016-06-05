module STARMAN
  class OsSpec
    def initialize
      @commands = {}
    end

    [:type, :soname, :ld_library_path, :hardware].each do |attr|
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

    attr_reader :version
    def version val = nil, &block
      if block_given?
        @version = VersionSpec.new block.call
      else
        @version = VersionSpec.new val if val
      end
      @version
    end

    attr_reader :commands
    def command val, &block
      @commands[val] = block
    end
  end
end
