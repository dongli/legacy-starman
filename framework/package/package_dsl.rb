module STARMAN
  module PackageDSL
    def self.included base
      base.extend self
    end

    [:homepage, :url, :mirror, :sha256, :version].each do |attr|
      class_eval <<-EOT
        def #{attr} val
          latest.#{attr} val
        end
      EOT
    end

    def depends_on other_package, **options
      latest.depends_on other_package, options
    end

    def latest
      eval "@@#{self.name.split('::').last}_latest ||= PackageSpec.new"
    end

    # To support multiple versions of package, but the history versions should
    # be limited.
    def history &block
      name = self.name.split('::').last
      eval "@@#{name}_history ||= {}"
      return eval "@@#{name}_history" if not block_given?
      spec = PackageSpec.new
      spec.instance_eval &block
      eval "@@#{name}_history[spec.version.to_s] = spec"
    end
  end
end
