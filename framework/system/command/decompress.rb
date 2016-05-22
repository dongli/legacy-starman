module STARMAN
  module System
    module Command
      def decompress file_path, *options
        args = ''
        if file_path =~ /\.tar.Z$/i
          system "tar xzf #{file_path} #{args}"
        elsif file_path =~ /\.(tar(\..*)?|tgz|tbz2)$/i
          system "tar xf #{file_path} #{args}"
        elsif file_path =~ /\.(gz)$/i
          system "gzip -d #{file_path}"
        elsif file_path =~ /\.(bz2)$/i
          system "bzip2 -d #{file_path}"
        elsif file_path =~ /\.(zip)$/i
          system "unzip -o #{file_path} 1> /dev/null"
        else
          if not options.include? :not_exit
            CLI.report_error "Unknown compression type of \"#{file_path}\"!"
          else
            return nil
          end
        end
      end
    end
  end
end
