module STARMAN
  class OS
    include OsDSL

    extend Forwardable
    def_delegators :@spec, :commands

    def initialize
      @spec = eval "@@#{self.class.name.split('::').last.downcase.to_sym}_spec"
    end

    class << self
      def init
        res = `uname`
        case res
        when /^Darwin */
          @@os = Mac.new
        when /^Linux */
          res = `cat /etc/*-release`
          case res
          when /Red Hat Enterprise Linux Server/
            @@os = RHEL.new
          when /Ubuntu/
            @@os = Ubuntu.new
          when /Fedora/
            @@os = Fedora.new
          when /CentOS/
            @@os = CentOS.new
          when /Debian GNU\/Linux/
            @@os = Debian.new
          when /SUSE Linux/
            @@os = Suse.new
          else
            CLI.report_error "Unknown OS type \"#{res}\"!"
          end
        when /^CYGWIN*/
          @@os = Cygwin.new
        else
          CLI.report_error "Unknown OS type \"#{res}\"!"
        end
        @@os.commands.each_key do |name|
          class_eval <<-EOT
            def self.#{name} *args
              @@os.commands[:#{name}].call *args
            end
          EOT
        end
      end

      def tag
        "#{@@os.type}_#{@@os.version.major_minor}"
      end

      def mac?
        @@os.type == :mac
      end

      def os_name
        @@os_name ||= self.name.split('::').last.downcase.to_sym
      end
    end
  end
end
