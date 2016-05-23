module STARMAN
  module PackageParams
    def self.included base
      base.extend self
    end

    DEFAULT_INSTALL_ROOT = '/opt/starman/software'

    def prefix
      if self.group_master
        slave_prefix
      elsif self.has_label? :group_master
        master_prefix
      else
        normal_prefix
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

    # Tag package for creating precompiled binary.
    def tag
      if self.has_label? :group_master
        master_tag
      elsif not self.group_master
        normal_tag
      end
    end

    private

    def slave_prefix
      slave_tags = []
      self.group_master.slaves.each do |slave|
        slave_tags << "#{slave.name}_#{slave.version.to_s}"
      end
      "#{DEFAULT_INSTALL_ROOT}/#{self.group_master.name}/#{slave_tags.join('-')}/#{slave_option_tag}/#{CompilerStore.active_compiler_set_index}"
    end

    def master_prefix
      slave_tags = []
      self.slaves.each do |slave|
        slave_tags << "#{slave.name}_#{slave.version.to_s}"
      end
      "#{DEFAULT_INSTALL_ROOT}/#{self.name}/#{slave_tags.join('-')}/#{master_option_tag}/#{CompilerStore.active_compiler_set_index}"
    end

    def normal_prefix
      name = self.class == Class ? package_name : self.name
      spec = self.class == Class ? self.latest : self
      "#{DEFAULT_INSTALL_ROOT}/#{name}/#{spec.version}/#{normal_option_tag}/#{CompilerStore.active_compiler_set_index}"
    end

    def slave_option_tag
      res = ''
      self.group_master.slaves.each do |slave|
        slave.options.each do |option_name, option_options|
          next if option_options.extra[:common]
          res << "#{option_name}_#{option_options.value}"
        end
      end
      Digest::SHA1.hexdigest(res)
    end

    def master_option_tag
      res = ''
      self.slaves.each do |slave|
        slave.options.each do |option_name, option_options|
          next if option_options.extra[:common]
          res << "#{option_name}_#{option_options.value}"
        end
      end
      Digest::SHA1.hexdigest(res)
    end

    def normal_option_tag
      res = ''
      self.options.each do |option_name, option_options|
        next if option_options.extra[:common]
        res << "#{option_name}_#{option_options.value}"
      end
      Digest::SHA1.hexdigest(res)
    end

    def master_tag
      res = "#{self.name}"
      self.slaves.each do |slave|
        res << "-#{slave.name}_#{slave.version}"
        res << "-#{slave.revision.keys.last}" if not slave.revision.empty?
      end
      res << "-#{OS.tag}"
      self.slaves.map { |slave| slave.languages }.flatten.uniq.each do |language|
        next if not CompilerStore.active_compiler_set.compiler(language)
        res << "-#{CompilerStore.active_compiler_set.compiler(language).tag(language)}"
      end
      res << "-#{master_option_tag}"
    end

    def normal_tag
      res = "#{self.name}-#{self.version}-#{OS.tag}"
      self.languages.each do |language|
        next if not CompilerStore.active_compiler_set.compiler(language)
        res << "-#{CompilerStore.active_compiler_set.compiler(language).tag(language)}"
      end
      res << "-#{revision.keys.last}" if not revision.empty?
      res << "-#{normal_option_tag}"
    end
  end
end
