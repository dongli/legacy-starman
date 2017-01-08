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

    def libexec
      "#{prefix}/libexec"
    end

    def frameworks
      "#{prefix}/Frameworks"
    end

    def share
      "#{prefix}/share"
    end

    def man
      "#{prefix}/share/man"
    end

    def pkg_config
      "#{lib}/pkgconfig"
    end

    def var
      "#{prefix}/var"
    end
  end
end
