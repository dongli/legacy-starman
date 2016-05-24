module STARMAN
  module PackageShortcuts
    def self.included base
      base.extend self
    end

    def bin
      "#{prefix}/bin"
    end

    def etc
      "#{prefix}/etc"
    end

    def inc
      "#{prefix}/include" if Dir.exist? "#{prefix}/include"
    end

    def lib
      "#{prefix}/lib" if Dir.exist? "#{prefix}/lib"
    end
  end
end
