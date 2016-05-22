module STARMAN
  module Command
    class Remove
      def accepted_options
        {
          :purely => OptionSpec.new(
            :desc => 'Remove package and its dependencies if they are not refered by other packages.',
            :accept_value => { :boolean => false }
          )
        }
      end

      def self.run

      end
    end
  end
end
