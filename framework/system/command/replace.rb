module STARMAN
  module System
    module Command
      def replace file_paths, before, after
        Array(file_paths).each do |file_path|
          content = File.read(file_path)
          content.gsub! before, after
          File.open(file_path, 'w') do |file|
            file.write content
            file.close
          end
        end
      end
    end
  end
end
