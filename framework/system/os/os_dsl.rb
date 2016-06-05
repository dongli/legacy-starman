module STARMAN
  module OsDSL
    def self.included base
      base.extend self
    end

    [:type, :version, :soname, :ld_library_path, :hardware].each do |attr|
      class_eval <<-EOT
        def #{attr} val = nil, &block
          spec.#{attr} val, &block
        end
      EOT
    end

    def command val, &block
      spec.command val, &block
    end

    def spec
      name = self.class == Class ? self.os_name : self.class.os_name
      eval "@@#{name}_spec ||= OsSpec.new"
    end
  end
end
