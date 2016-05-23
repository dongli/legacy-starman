module STARMAN
  module PackageParams
    def self.included base
      base.extend self
    end

    DEFAULT_INSTALL_ROOT = '/opt/starman/software'

    def prefix
      name = self.class == Class ? package_name : self.name
      spec = self.class == Class ? self.latest : self
      if self.group_master
        slave_tags = []
        self.group_master.slaves.each do |slave|
          slave_tags << "#{slave.name}_#{slave.version.to_s}"
        end
        "#{DEFAULT_INSTALL_ROOT}/#{self.group_master.name}/#{slave_tags.join('-')}/#{CompilerStore.active_compiler_set_index}"
      else
        "#{DEFAULT_INSTALL_ROOT}/#{name}/#{spec.version}/#{CompilerStore.active_compiler_set_index}"
      end
    end

    def persist
      name = self.class == Class ? package_name : self.name
      spec = self.class == Class ? self.latest : self
      "#{DEFAULT_INSTALL_ROOT}/#{name}/persist"
    end

    def inc
      "#{prefix}/include" if Dir.exist? "#{prefix}/include"
    end

    def lib
      "#{prefix}/lib" if Dir.exist? "#{prefix}/lib"
    end
  end
end
