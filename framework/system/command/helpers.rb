module STARMAN
  module System
    module Command
      def system_command? cmd
        `which #{cmd} 2>&1`
        $?.success?
      end

      def full_command_path cmd
        `which #{cmd}`.chomp
      end

      def run cmd, *options
        if cmd == 'make' and not options.include? :single_job
          options << "-j#{CommandLine.options[:'make-jobs'].value}"
        end
        options.delete(:single_job)
        cmd_str = "#{cmd} #{options.join(' ')}"
        if CommandLine.options[:debug].value
          CLI.blue_arrow cmd_str
          print File.open(System::Shell.rc_file, 'r').read
        else
          CLI.blue_arrow cmd_str, :truncate
        end
        if not CommandLine.options[:verbose].value
          cmd_str << " 1>#{ConfigStore.package_root}/stdout.#{Process.pid}" +
                     " 2>#{ConfigStore.package_root}/stderr.#{Process.pid}"
        end
        system cmd_str
        if not $?.success?
          CLI.report_error "Failed to run #{cmd_str}.\n"
        end
      end

      def work_in dir
        CLI.report_error 'No work block is given!' if not block_given?
        cd dir
        yield
        cd :back
      end
    end
  end
end
