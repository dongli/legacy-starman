module STARMAN
  class Package
    include PackageDSL
    include PackageInstallParams

    extend Forwardable
    def_delegators :@latest, :homepage, :url, :mirror, :sha256, :version, :dependencies

    attr_reader :latest, :history

    def initialize
      name = self.class.name.split('::').last
      @latest = eval("@@#{name}_latest")
      @history = eval("defined? @@#{name}_history") ? eval("@@#{name}_history") : {}
    end
  end
end
