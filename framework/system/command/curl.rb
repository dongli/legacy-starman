module STARMAN
  module System
    module Command
      def curl url, root, **options
        if system_command? :curl
          filename = options[:rename] ? options[:rename] : File.basename(URI.parse(url).path)
          system "curl -f#L -C - -o #{root}/#{filename} #{url}"
          CLI.report_error "Failed to download #{CLI.red url}!" if not $?.success?
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
