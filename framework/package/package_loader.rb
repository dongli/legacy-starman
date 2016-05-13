module STARMAN
  class PackageLoader
    @@packages = {}
    Dir.glob("#{ENV['STARMAN_ROOT']}/packages/*.rb").each do |file|
      name = File.basename(file, '.rb').to_sym
      @@packages[name] = { :file => file }
    end

    def self.load_package name
      load @@packages[name][:file]
    end

    def self.init
      @@packages.each_key do |name|
        load_package name
      end
    end

    def self.has_package? name
      @@packages.has_key? name.to_s.downcase.to_sym
    end
  end
end
