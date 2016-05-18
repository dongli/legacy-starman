module STARMAN
  module System
    module Command
      def curl url, root, **options
        if system_command? :curl
          filename = options[:rename] ? options[:rename] : File.basename(URI.parse(url).path)
          system "curl -f#L -C - -o #{root}/#{filename} #{url}"
        end
      end
    end
  end
end
