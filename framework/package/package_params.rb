module STARMAN
  module PackageParams
    def self.included base
      base.extend self
    end

    def prefix options = {}
      name = self.has_label?(:parasite) ? self.labels[:parasite][:into] : self.name
      package = PackageLoader.packages[name][:instance]
      if package.has_label? :group_master
        "#{ConfigStore.install_root}/#{name}/#{package.version}/#{master_tag options}"
      elsif not self.group_master
        "#{ConfigStore.install_root}/#{name}/#{package.version}/#{normal_tag options}"
      else
        "#{ConfigStore.install_root}/#{package.group_master.name}/#{package.group_master.version}/#{slave_tag options}"
      end
    end

    def persist
      "#{ConfigStore.install_root}/#{self.name}/persist"
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

    def slave_tag options = {}
      res = "#{self.group_master.name}"
      self.group_master.slaves.each do |slave|
        res << "-#{slave.name}_#{slave.version}"
        res << "-#{slave.revision.keys.last}" if not slave.revision.empty?
      end
      res << "-#{OS.tag}"
      if not self.group_master.has_label? :compiler and not self.group_master.has_label? :compiler_agnostic
        res << "-#{CompilerStore.active_compiler_set.tag}"
      end
      self.group_master.slaves.each do |slave|
        slave.options.each do |option_name, option_options|
          next if option_options.extra[:profile] == false
          res << "#{option_name}_#{option_options.value}"
        end
      end
      return res if options[:debug]
      Digest::SHA1.hexdigest res
    end

    def master_tag options = {}
      res = self.name.to_s
      self.slaves.each do |slave|
        res << "-#{slave.name}_#{slave.version}"
        res << "-#{slave.revision.keys.last}" if not slave.revision.empty?
      end
      res << "-#{OS.tag}"
      if not self.has_label? :compiler and not self.has_label? :compiler_agnostic
        res << "-#{CompilerStore.active_compiler_set.tag}"
      end
      self.slaves.each do |slave|
        slave.options.each do |option_name, option_options|
          next if option_options.extra[:profile] == false
          res << "#{option_name}_#{option_options.value}"
        end
      end
      return res if options[:debug]
      Digest::SHA1.hexdigest res
    end

    def normal_tag options = {}
      res = "#{self.name}-#{self.version}-#{OS.tag}"
      if not self.has_label? :compiler and not self.has_label? :compiler_agnostic
        res << "-#{CompilerStore.active_compiler_set.tag}"
      end
      res << "-#{revision.keys.last}" if not revision.empty?
      self.options.each do |option_name, option_options|
        next if option_options.extra[:profile] == false
        res << "#{option_name}_#{option_options.value}"
      end
      return res if options[:debug]
      Digest::SHA1.hexdigest res
    end
  end
end
