module STARMAN
  class OS
    include OsDSL

    attr_reader :spec

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
      end

      def tag
        "#{@@os.type}_#{@@os.version.major_minor}"
      end

      protected

      def os_name
        @@os_name ||= self.name.split('::').last.downcase.to_sym
      end
    end
  end
end
