module STARMAN
  module Command
    class Update
      extend FileUtils

      def self.accepted_options
        {}
      end

      def self.__run__
        work_in ENV['STARMAN_ROOT'] do
          if Dir.exist? '.git'
            system 'git', 'pull'
          else
            CLI.report_error "Sorry, you haven't installed STARMAN using #{CLI.red 'git'}!"
          end
        end
      end
    end
  end
end
