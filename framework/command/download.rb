module STARMAN
  module Command
    class Download
      def self.accepted_options
        {}
      end

      def self.run
        CommandLine.packages.values.reverse_each do |package|
          next if package.has_label? :group_master
          PackageDownloader.run package
        end
      end
    end
  end
end
