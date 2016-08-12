module STARMAN
  module Command
    class Upload
      def self.accepted_options
        {
          :force => OptionSpec.new(
            :desc => 'Force to upload packages no matter other conditions.',
            :accept_value => { :boolean => false }
          )
        }
      end

      def self.run
        Storage.check_connection
        CommandLine.packages.values.reverse_each do |package|
          next if package.group_master
          if not PackageInstaller.installed? package
            CLI.report_error "Package #{CLI.red package.name} has not been installed!"
          end
          if Storage.uploaded? package
            if CommandLine.options[:force].value
              begin
                Storage.delete! package
              rescue => e
                CLI.report_error "Failed to delete #{CLI.red package.name} on Qiniu!\n#{e}"
              end
            else
              CLI.report_warning "Package #{CLI.blue package.name} has been uploaded."
              next
            end
          end
          begin
            Storage.upload! package
            PackageBinary.write_record package
          rescue => e
            CLI.report_error "Failed to upload #{CLI.red package.name} to Qiniu!\n#{e}"
          end
        end
      end
    end
  end
end
