module STARMAN
  module System
    module Command
      def system_command? cmd
        `which #{cmd} 2>&1`
        $?.success?
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
