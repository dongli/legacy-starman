module STARMAN
  class OS
    include OsDSL

    extend Forwardable
    def_delegators :@spec, :commands

    def initialize
      @spec = eval "@@#{self.class.name.split('::').last.downcase.to_sym}_spec"
      inherit_parent_spec self.class
    end

    def inherit_parent_spec os
      if os.superclass and os.superclass != STARMAN::OS
        spec = eval "@@#{os.superclass.name.split('::').last.downcase.to_sym}_spec"
        @spec.inherit spec
        inherit_parent_spec os.superclass
      end
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
        [:version, :soname, :ld_library_path].each do |attr|
          class_eval "def self.#{attr}; @@os.#{attr}; end"
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

      def linux?
        @@os.type == :ubuntu
      end

      def os_name
        self.name.split('::').last.downcase.to_sym
      end
    end
  end
end
