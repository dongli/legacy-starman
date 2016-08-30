module STARMAN
  class Package
    include System::Command
    include PackageDSL
    include PackageParams
    include PackageDefaultMethods
    include PackageShortcuts
    include PackageHelpers

    extend Forwardable
    def_delegators :@latest, :homepage, :url, :mirror, :sha256, :version
    def_delegators :@latest, :labels, :languages, :has_label?, :has_language?
    def_delegators :@latest, :group_master, :slave, :slaves, :patch
    def_delegators :@latest, :filename, :revision, :options, :dependencies

    attr_reader :name, :latest, :external_binary, :history

    def initialize
      @name = self.class.name.split('::').last.downcase.to_sym
      @latest = eval("@@#{@name}_latest")
      @external_binary = eval("defined? @@#{@name}_external_binary") ? eval("@@#{@name}_external_binary") : {}
      # Find out matched external binary.
      @external_binary.each do |os, spec|
        os = eval os
        next if os.first != OS.type or not eval "OS.version #{os.last.split.first} '#{os.last.split.last}'"
        @external_binary = spec
      end
      @history = eval("defined? @@#{@name}_history") ? eval("@@#{@name}_history") : {}
    end

    def profile
      option_profile = {}
      self.options.each_key do |name|
        next if self.options[name].extra[:common]
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

    def self.package_name
      self.name.split('::').last.downcase.to_sym
    end

    def self.slaves
      latest = eval("@@#{package_name}_latest")
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
