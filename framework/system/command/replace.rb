module STARMAN
  module System
    module Command
      def replace file_paths, before, after
        Array(file_paths).each do |file_path|
          content = File.open(file_path, 'r').read
          content.gsub! before, after
          File.open(file_path, 'w').write content
        end
      end
    end
  end
end
