module STARMAN
  module PackageDefaultMethods
    def self.included base
      base.extend self
    end

    def pre_install
    end

    def install
      CLI.report_error "Package #{CLI.red self.name} does not provide install method!"
    end

    def post_install
    end
  end
end
