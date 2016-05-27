module STARMAN
  module PackageParams
    def self.included base
      base.extend self
    end

    DEFAULT_INSTALL_ROOT = '/opt/starman/software'

    def prefix debug = false
      name = self.class == Class ? package_name : self.name
      # <install_root>/<package_name>/<package_version>/<sha1>
      if self.has_label? :group_master
        "#{DEFAULT_INSTALL_ROOT}/#{name}/#{self.version}/#{master_tag debug}"
      elsif not self.group_master
        "#{DEFAULT_INSTALL_ROOT}/#{name}/#{self.version}/#{normal_tag debug}"
      else
        "#{DEFAULT_INSTALL_ROOT}/#{self.group_master.name}/#{self.group_master.version}/#{slave_tag debug}"
      end
    end

    def persist
      name = self.class == Class ? package_name : self.name
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

    def slave_tag debug = false
      res = "#{self.group_master.name}"
      self.group_master.slaves.each do |slave|
        res << "-#{slave.name}_#{slave.version}"
        res << "-#{slave.revision.keys.last}" if not slave.revision.empty?
      end
      res << "-#{OS.tag}"
      res << "-#{CompilerStore.active_compiler_set.tag}" if not self.group_master.has_label? :compiler
      self.group_master.slaves.each do |slave|
        slave.options.each do |option_name, option_options|
          next if option_options.extra[:common]
          res << "#{option_name}_#{option_options.value}"
        end
      end
      return res if debug
      Digest::SHA1.hexdigest res
    end

    def master_tag debug = false
      name = self.class == Class ? package_name : self.name
      res = name.to_s
      self.slaves.each do |slave|
        res << "-#{slave.name}_#{slave.version}"
        res << "-#{slave.revision.keys.last}" if not slave.revision.empty?
      end
      res << "-#{OS.tag}"
      res << "-#{CompilerStore.active_compiler_set.tag}" if not self.has_label? :compiler
      self.slaves.each do |slave|
        slave.options.each do |option_name, option_options|
          next if option_options.extra[:common]
          res << "#{option_name}_#{option_options.value}"
        end
      end
      return res if debug
      Digest::SHA1.hexdigest res
    end

    def normal_tag debug = false
      name = self.class == Class ? package_name : self.name
      res = "#{name}-#{self.version}-#{OS.tag}"
      res << "-#{CompilerStore.active_compiler_set.tag}" if not self.has_label? :compiler
      res << "-#{revision.keys.last}" if not revision.empty?
      self.options.each do |option_name, option_options|
        next if option_options.extra[:common]
        res << "#{option_name}_#{option_options.value}"
      end
      return res if debug
      Digest::SHA1.hexdigest res
    end
  end
end
