module STARMAN
  class OsSpec
    def initialize
      @commands = {}
    end

    [:type, :soname, :ld_library_path, :hardware].each do |attr|
      class_eval <<-EOT
        def #{attr} val = nil, &block
          if block_given?
            begin
              @#{attr} = block.call
            rescue NoMethodError, Errno::ENOENT
            end
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
        res = block.call
        @version = VersionSpec.new(res) rescue res
      else
        @version = VersionSpec.new val if val
      end
      @version
    end

    attr_reader :commands
    def command val, &block
      @commands[val] = block
    end

    def inherit spec
      spec.commands.each do |val, block|
        next if @commands.has_key? val
        @commands[val] = block
      end
      [:version, :soname, :ld_library_path, :hardware].each do |attr|
        instance_eval "@#{attr} ||= spec.#{attr}"
      end
    end
  end
end
