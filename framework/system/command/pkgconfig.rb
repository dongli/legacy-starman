module STARMAN
  module System
    module Command
      def pkgconfig package, option
        case option
        when :version
          res = `pkg-config #{package} --modversion`
        else
          CLI.report_error "Option #{CLI.red option} to pkg-config is invalid!"
        end
        res.strip
      end
    end
  end
end
