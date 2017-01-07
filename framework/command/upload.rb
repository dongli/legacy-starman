module STARMAN
  module Command
    class Upload
      def self.accepted_options
        {
          :'without-depends' => OptionSpec.new(
            desc: 'Do not upload dependencies.',
            accept_value: { boolean: false }
          ),
          force: OptionSpec.new(
            desc: 'Force to upload packages no matter other conditions.',
            accept_value: { boolean: false }
          )
        }
      end

      def self.__run__
        Storage.check_connection
        CommandLine.packages.each_value do |package|
          next if package.group_master
          next if CommandLine.options[:'without-depends'].value and not CommandLine.direct_packages.include? package.name
          if not Install.installed? package
            CLI.report_error "Package #{CLI.red package.name} has not been installed!"
          end
          if Storage.uploaded? package
            if CommandLine.options[:force].value
              begin
                Storage.delete! package
              rescue => e
                CLI.report_error "Failed to delete #{CLI.red package.name} on #{CLI.blue Storage.adapter_name}!\n#{e}"
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
            CLI.report_error "Failed to upload #{CLI.red package.name} to #{CLI.blue Storage.adapter_name}!\n#{e}"
          end
        end
      end
    end
  end
end
