module STARMAN
  class PackageAlias
    Alias = {
      mpi: [:openmpi]
    }.freeze

    def self.lookup name
      return nil if not Alias.has_key? name
      case Alias[name]
      when Array
        if ConfigStore.defaults.has_key? name and Alias[name].include? ConfigStore.defaults[name].to_sym
          return ConfigStore.defaults[name].to_sym
        else
          CLI.report_error "Encounter ambiguous package alias #{CLI.red name}: #{Alias[name]}!"
        end
      else
        Alias[name]
      end
    end
  end
end
