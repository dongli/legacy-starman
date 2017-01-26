module STARMAN
  class PackageLabels
    Labels = [
      :compiler_agnostic,
      :external_binary,
      :system_conflict,
      :parasite,
      :system_first
    ].freeze

    def self.valid? label
      Labels.include? label
    end
  end
end
