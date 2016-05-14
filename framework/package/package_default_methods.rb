module STARMAN
  module PackageDefaultMethods
    def self.included base
      base.extend self
    end

    def check_system
    end
  end
end
