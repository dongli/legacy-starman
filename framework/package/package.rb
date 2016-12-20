module STARMAN
  class Package
    include System::Command
    include FileUtils
    include PackageDSL
    include PackageParams
    include PackageDefaultMethods
    include PackageShortcuts
    include PackageHelpers
    include PackageResource

    # Delegate methods to instance methods.
    extend Forwardable
    def_delegators :@latest, :homepage, :url, :mirror, :sha256, :version
    def_delegators :@latest, :labels, :languages, :has_label?, :has_language?
    def_delegators :@latest, :group_master, :slave, :slaves, :patches
    def_delegators :@latest, :filename, :revision, :options, :dependencies

    # Delegate methods to class methods
    [:labels].each do |method|
      class_eval <<-RUBY
        def self.#{method}
          self.class_variable_get(:"@@\#{self.name}_latest").#{method}
        end
      RUBY
    end
    [:has_label?].each do |method|
      class_eval <<-RUBY
        def self.#{method} value
          self.class_variable_get(:"@@\#{self.name}_latest").#{method} value
        end
      RUBY
    end

    attr_reader :name, :latest, :external_binary, :history, :resources

    def initialize
      @name = self.class.name
      @latest = eval("@@#{@name}_latest")
      @external_binary = eval("defined? @@#{@name}_external_binary") ? eval("@@#{@name}_external_binary") : {}
      # Find out matched external binary.
      @external_binary.each do |os, spec|
        os = eval os
        next if os.first != OS.type
        next if os.size == 2 and not eval "OS.version #{os.last.split.first} '#{os.last.split.last}'"
        @external_binary = spec
      end
      @history = eval("defined? @@#{@name}_history") ? eval("@@#{@name}_history") : {}
      @resources = eval("defined? @@#{@name}_resources") ? eval("@@#{@name}_resources") : {}
    end

    def profile
      option_profile = {}
      self.options.each_key do |name|
        next if self.options[name].extra[:profile] == false
        option_profile[name] = self.options[name].value
      end
      spec = has_label?(:external_binary) ? external_binary : self
      {
        :name => self.name,
        :version => self.version.to_s,
        :revision => spec.revision,
        :sha256 => spec.sha256,
        :options => option_profile
      }
    end

    singleton_class.send(:alias_method, :old_name, :name)
    def self.name
      self.old_name.split('::').last.downcase.to_sym
    end

    def self.slaves
      latest = eval("@@#{name}_latest")
      latest.slaves
    end

    def self.print_options package, options = {}
      res = ' '.ljust(options[:indent], ' ') || ''
      package.options.each do |option_name, option_spec|
        next if option_spec.extra and option_spec.extra[:common]
        res << "#{CLI.blue option_name}: #{option_spec.inspect}\n"
      end
      res
    end
  end
end
