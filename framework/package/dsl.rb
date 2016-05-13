module STARMAN
  module PackageDSL
    def self.included base
      base.extend self
    end

    [:homepage, :url, :mirror, :version].each do |attr|
      class_eval <<-EOT
        def #{attr} val
          spec.#{attr} val
        end
      EOT
    end

    def spec
      eval "@@#{self.name.split('::').last} ||= PackageSpec.new"
    end
  end
end
