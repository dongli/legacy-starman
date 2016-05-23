module STARMAN
  class Package
    include System::Command
    include PackageDSL
    include PackageParams
    include PackageDefaultMethods

    extend Forwardable
    def_delegators :@latest, :homepage, :url, :mirror, :sha256, :version
    def_delegators :@latest, :labels, :languages, :has_label?, :has_language?
    def_delegators :@latest, :group_master, :slave, :slaves
    def_delegators :@latest, :filename, :revision, :options, :dependencies

    attr_reader :name, :latest, :history

    def initialize
      @name = self.class.name.split('::').last.downcase.to_sym
      @latest = eval("@@#{@name}_latest")
      @history = eval("defined? @@#{@name}_history") ? eval("@@#{@name}_history") : {}
    end

    def profile
      {
        :name => self.name,
        :version => self.version.to_s,
        :revision => self.revision,
        :sha256 => self.sha256
      }
    end

    def self.package_name
      self.name.split('::').last.downcase.to_sym
    end
  end
end
