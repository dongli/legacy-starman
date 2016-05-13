module STARMAN
  class PackageSpec
    [:homepage, :url, :mirror, :sha256, :version].each do |attr|
      attr_reader attr
      class_eval <<-EOT
        def #{attr} val = nil
          @#{attr} = val if val
          @#{attr}
        end
      EOT
    end

    attr_reader :dependencies

    def initialize
      @dependencies = {}
    end

    def depends_on other_package, **options
      @dependencies[other_package] = options
    end
  end
end
