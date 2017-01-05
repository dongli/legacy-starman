module STARMAN
  module System
    module Command
      include FileUtils

      def curl url, root, **options
        if system_command? :curl
          filename = options[:rename] ? options[:rename] : File.basename(URI.parse(url).path)
          system "curl -f#L -C - -o #{root}/#{filename} #{url}"
          unless $?.success?
            if $?.exitstatus == 33
              rm "#{root}/#{filename}"
              curl url, root, options
            end
            CLI.report_error "Failed to download #{CLI.red url}!"
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
