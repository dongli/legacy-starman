module STARMAN
  module Command
    class Config
      def self.accepted_options
        {}
      end

      def self.__run__
        editor = 'vim'
        system "#{editor} -c 'set filetype=yaml' #{CommandLine.options[:config].value}"
      end
    end
  end
end
