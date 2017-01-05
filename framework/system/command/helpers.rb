module STARMAN
  module System
    module Command
      def system_command? cmd
        `which #{cmd} 2>&1`
        $?.success?
      end

      def process_running? pid
        if pid.class == String
          pid = pid.chomp
          return false if pid == ''
        end
        begin
          Process.kill 0, pid.to_i
          true
        rescue Errno::ESRCH
          false
        end
      end

      def full_command_path cmd
        `which #{cmd}`.chomp
      end

      def url_exist? url
        uri = URI(url)
        begin
          request = Net::HTTP.new uri.host
          response= request.request_head uri.path
          response.code.to_i == 200
        rescue
        end
      end
    end
  end
end
