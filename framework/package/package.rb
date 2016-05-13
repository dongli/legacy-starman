module STARMAN
  class Package
    include PackageDSL

    extend Forwardable
    def_delegators :@spec, :homepage, :url, :mirror, :version

    def initialize
      @spec = eval("@@#{self.class.name.split('::').last}")
    end
  end
end
