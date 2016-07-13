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
      "#{prefix}/include"
    end

    def lib
      "#{prefix}/lib"
    end

    def share
      "#{prefix}/share"
    end

    def pkg_config
      "#{lib}/pkgconfig"
    end
  end
end
