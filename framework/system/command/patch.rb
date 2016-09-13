module STARMAN
  module System
    module Command
      def patch_data data
        File.open('patch.diff', 'w') do |file|
          file << data
          file.close
        end
        patch_file 'patch.diff'
      end

      def patch_file path
        system "patch --ignore-whitespace -N -p1 < #{path}"
        CLI.report_error 'Failed to apply patch!' if not $?.success?
      end
    end
  end
end
