module STARMAN
  module Command
    class Call
      def self.accepted_options
        {
          command: OptionSpec.new(
            desc: 'Command to be called.',
            accept_value: :string 
          )
        }
      end

      def self.__run__
        package = CommandLine.direct_packages.values.first
        package.call
      end
    end
  end
end