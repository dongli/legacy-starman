module STARMAN
  class PackageSpec
    attr_reader :homepage, :url, :mirror, :version

    def initialize
    end

    [:homepage, :url, :mirror, :version].each do |attr|
      class_eval <<-EOT
        def #{attr} val = nil
          @#{attr} = val if val
          @#{attr}
        end
      EOT
    end
  end
end
