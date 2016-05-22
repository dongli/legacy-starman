module STARMAN
  module OsDSL
    def self.included base
      base.extend self
    end

    [:type, :version].each do |attr|
      class_eval <<-EOT
        def #{attr} val = nil, &block
          spec.#{attr} val, &block
        end
      EOT
    end

    def spec
      eval "@@#{os_name}_spec ||= OsSpec.new"
    end
  end
end
