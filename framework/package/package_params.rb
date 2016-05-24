module STARMAN
  module PackageParams
    def self.included base
      base.extend self
    end

    DEFAULT_INSTALL_ROOT = '/opt/starman/software'

    def prefix
      # <install_root>/<package_name>/<package_version>/<sha1>
      if self.has_label? :group_master
        "#{DEFAULT_INSTALL_ROOT}/#{self.name}/#{self.version}/#{master_tag}"
      elsif not self.group_master
        "#{DEFAULT_INSTALL_ROOT}/#{self.name}/#{self.version}/#{normal_tag}"
      else
        "#{DEFAULT_INSTALL_ROOT}/#{self.group_master.name}/#{self.group_master.version}/#{slave_tag}"
      end
    end

    def persist
      name = self.class == Class ? package_name : self.name
      spec = self.class == Class ? self.latest : self
      "#{DEFAULT_INSTALL_ROOT}/#{name}/persist"
    end

    # Tag package for creating precompiled binary.
    def tag
      if self.has_label? :group_master
        "#{self.name}-#{self.version}-#{master_tag}"
      elsif not self.group_master
        "#{self.name}-#{self.version}-#{normal_tag}"
      else
        "#{self.group_master.name}-#{self.group_master.version}-#{slave_tag}"
      end
    end

    private

    def slave_tag
      res = "#{self.group_master.name}"
      self.group_master.slaves.each do |slave|
        res << "-#{slave.name}_#{slave.version}"
        res << "-#{slave.revision.keys.last}" if not slave.revision.empty?
      end
      res << "-#{OS.tag}-#{CompilerStore.active_compiler_set.tag}"
      self.group_master.slaves.each do |slave|
        slave.options.each do |option_name, option_options|
          next if option_options.extra[:common]
          res << "#{option_name}_#{option_options.value}"
        end
      end
      Digest::SHA1.hexdigest res
    end

    def master_tag
      res = "#{self.name}"
      self.slaves.each do |slave|
        res << "-#{slave.name}_#{slave.version}"
        res << "-#{slave.revision.keys.last}" if not slave.revision.empty?
      end
      res << "-#{OS.tag}-#{CompilerStore.active_compiler_set.tag}"
      self.slaves.each do |slave|
        slave.options.each do |option_name, option_options|
          next if option_options.extra[:common]
          res << "#{option_name}_#{option_options.value}"
        end
      end
      Digest::SHA1.hexdigest res
    end

    def normal_tag
      res = "#{self.name}-#{self.version}-#{OS.tag}-#{CompilerStore.active_compiler_set.tag}"
      res << "-#{revision.keys.last}" if not revision.empty?
      self.options.each do |option_name, option_options|
        next if option_options.extra[:common]
        res << "#{option_name}_#{option_options.value}"
      end
      Digest::SHA1.hexdigest res
    end
  end
end
