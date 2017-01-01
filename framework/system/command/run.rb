module STARMAN
  module System
    module Command
      def run cmd, *options
        CompilerStore.set_default_flags
        # Print command onto screen first.
        cmd_str = "#{cmd} #{options.select { |option| option.class == String }.join(' ')}"
        if CommandLine.options[:debug].value
          CLI.blue_arrow cmd_str
        else
          CLI.blue_arrow cmd_str, :truncate
        end
        # Handle command if necessary.
        case cmd
        when 'make'
          handle_make_command options
        when 'sudo'
          handle_sudo_command options
        end
        cmd_str = "#{cmd} #{options.select { |option| option.class == String }.join(' ')}"
        if not CommandLine.options[:verbose].value and
           not options.include? :screen_output and
           not options.include? :capture_output
          cmd_str << " 1>#{ConfigStore.package_root}/stdout.#{Process.pid}" +
                     " 2>#{ConfigStore.package_root}/stderr.#{Process.pid}"
        end
        if options.include? :capture_output
          res = `#{sources} #{cmd_str}`
        else
          system sources + cmd_str
        end
        if not $?.success? and not options.include? :skip_error
          CLI.report_error "Failed to run #{cmd_str}.\n"
        end
        CompilerStore.unset_flags
        return res if options.include? :capture_output
      end

      private

      def handle_make_command options
        options << "-j#{CommandLine.options[:'make-jobs'].value}" unless options.include? :single_job
        options.delete :single_job
      end

      def handle_sudo_command options
        return unless options.include? :preserve_ld_library_path
        i = options.index { |option| option =~ /^[^-]/ }
        return unless i < options.size
        options.insert i, "#{OS.ld_library_path}=#{ENV[OS.ld_library_path]}"
      end

      def sources
        System::Shell.source_files.inject('') { |s, x| s << "source #{x} && " }
      end
    end
  end
end
