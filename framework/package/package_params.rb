module STARMAN
  module PackageParams
    def self.included base
      base.extend self
    end

    DEFAULT_INSTALL_ROOT = '/opt/starman/software'

    def __get_data
      if self.class == Class
        name = self.name.split('::').last.downcase
        spec = self.latest
      else
        name = self.class.name.split('::').last.downcase
        spec = self
      end
      return name, spec
    end

    def prefix
      name, spec = __get_data
      "#{DEFAULT_INSTALL_ROOT}/#{name}/#{spec.version}"
    end

    def persist
      name, _spec = __get_data
      "#{DEFAULT_INSTALL_ROOT}/#{name}/persist"
    end
  end
end
