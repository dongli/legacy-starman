module STARMAN
  module PackageDefaultMethods
    def self.included base
      base.extend self
    end

    def export_env
    end

    def pre_install
    end

    def post_install
    end
  end
end
