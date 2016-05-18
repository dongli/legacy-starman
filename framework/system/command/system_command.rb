module STARMAN
  module System
    module Command
      def system_command? cmd
        `which #{cmd} 2>&1`
        $?.success?
      end
    end
  end
end
