module STARMAN
  module PackageParams
    def self.included base
      base.extend self
    end

    DEFAULT_INSTALL_ROOT = '/opt/starman/software'

    def prefix
      name = self.class == Class ? package_name : self.name
      spec = self.class == Class ? self.latest : self
      "#{DEFAULT_INSTALL_ROOT}/#{name}/#{spec.version}/#{CompilerStore.active_compiler_set_index}"
    end

    def persist
      name = self.class == Class ? package_name : self.name
      spec = self.class == Class ? self.latest : self
      "#{DEFAULT_INSTALL_ROOT}/#{name}/persist"
    end
  end
end
