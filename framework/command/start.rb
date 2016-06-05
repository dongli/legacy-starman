module STARMAN
  module Command
    class Start
      def self.accepted_options
        {}
      end

      def self.run
        CommandLine.packages.each_value do |package|
          next if not package.respond_to? :start
          package.start
        end
      end
    end
  end
end
