module STARMAN
  module System
    module Command
      def tar src_path, dst_path, **options
        work_in src_path do
          run "tar czf #{dst_path} ."
        end
      end
    end
  end
end
