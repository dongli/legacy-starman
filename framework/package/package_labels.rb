module STARMAN
  class PackageLabels
    Labels = [
      :compiler_agnostic,
      :external_binary,
      :system_conflict
    ].freeze

    def self.valid? label
      Labels.include? label
    end
  end
end
