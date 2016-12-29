module STARMAN
  module System
    module Command
      def wget url, root, **options
        if system_command? :wget
          filename = options[:rename] ? options[:rename] : File.basename(URI.parse(url).path)
          system "wget -c -O #{root}/#{filename} #{url}"
          CLI.report_error "Failed to download #{CLI.red url}!" if not $?.success?
        end
      end
    end
  end
end
