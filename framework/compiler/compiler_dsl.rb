module STARMAN
  module CompilerDSL
    def self.included base
      base.extend self
    end

    [:vendor, :version].each do |attr|
      class_eval <<-EOT
        def #{attr} val = nil, &block
          spec.#{attr} val, &block
        end
      EOT
    end

    [:language].each do |attr|
      class_eval <<-EOT
        def #{attr} val, **options
          spec.#{attr} val, options
        end
      EOT
    end

    [:flag].each do |attr|
      class_eval <<-EOT
        def #{attr} val
          spec.#{attr} val
        end
      EOT
    end

    def feature val, &block
      spec.feature val, &block
      class_eval <<-EOT
        def feature_#{val}?
          spec.features[val.to_sym]
        end
      EOT
    end

    def spec
      eval "@@#{compiler_name}_spec ||= CompilerSpec.new"
    end
  end
end
