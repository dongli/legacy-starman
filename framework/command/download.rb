module STARMAN
  module Command
    class Download
      def self.accepted_options
        {
          :'local-build' => OptionSpec.new(
            desc: 'Force to build package locally from source codes.',
            accept_value: { boolean: false }
          ),
          :'without-depends' => OptionSpec.new(
            desc: 'Do not download dependencies.',
            accept_value: { boolean: false }
          )
        }
      end

      def self.run
        CommandLine.packages.each_value do |package|
          next if package.has_label? :group_master
          PackageDownloader.run package
        end
      end
    end
  end
end
