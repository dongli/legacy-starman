module STARMAN
  module Command
    class Config
      extend System::Command

      def self.accepted_options
        {}
      end

      def self.__run__
        if system_command? 'vim'
          system "vim -c 'set filetype=yaml' #{CommandLine.option(:config)}"
        elsif system_command? 'vi'
          system "vi #{CommandLine.option(:config)}"
        else
          CLI.report_error 'Do not know which editor to use.'
        end
      end
    end
  end
end
