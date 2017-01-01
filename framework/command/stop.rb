module STARMAN
  module Command
    class Stop
      def self.accepted_options
        {}
      end

      def self.__run__
        CommandLine.packages.each_value do |package|
          next if not package.respond_to? :stop
          package.stop
        end
      end
    end
  end
end
