module STARMAN
  module System
    module Command
      include FileUtils

      CONTENT_TYPES = {
        json: 'application/json',
        octet_stream: 'application/octet-stream'
      }.freeze

      def curl url, root, options = {}
        if system_command? :curl
          options[:method] ||= :get
          case options[:method]
          when :get
            filename = options[:rename] ? options[:rename] : File.basename(URI.parse(url).path)
            system "curl -f#L -C - -o #{root}/#{filename} #{url}"
            unless $?.success?
              if $?.exitstatus == 33
                rm "#{root}/#{filename}"
                curl url, root, options
              end
              CLI.report_error "Failed to download #{CLI.red url}!"
            end
          when :put, :post
            args = ["-X #{options[:method].upcase}"]
            args << "-u '#{options[:username]}:#{options[:password]}'" if options[:username] and options[:password]
            args << "-d '#{options[:payload]}'" if options[:payload]
            args << "--data-binary '@#{root}'" if root
            args << "-H 'Content-Type: #{CONTENT_TYPES[options[:content_type]]}'" if options[:content_type]
            system "curl #{args.join(' ')} #{url}"
          when :delete
            args = ["-X #{options[:method].upcase}"]
            args << "-u '#{options[:username]}:#{options[:password]}'" if options[:username] and options[:password]
            system "curl #{args.join(' ')} #{url}"
          end
        end
      end

      def url_exist? url
        if system_command? :curl
          `curl --silent --head --fail #{url}`
          $?.success?
        end
      end
    end
  end
end
