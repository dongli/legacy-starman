module STARMAN
  module System
    module Command
      def patch data
        File.open('patch.diff', 'w') do |file|
          file << data
          file.close
        end
        system 'patch --ignore-whitespace -N -p1 < patch.diff'
        if not $?.success?
          CLI.report_error 'Failed to apply patch!'
        end
      end
    end
  end
end
