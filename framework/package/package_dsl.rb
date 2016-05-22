module STARMAN
  module PackageDSL
    def self.included base
      base.extend self
    end

    [:homepage, :url, :mirror, :sha256, :version, :filename].each do |attr|
      class_eval <<-EOT
        def #{attr} val
          latest.#{attr} val
        end
      EOT
    end

    def languages *val
      latest.languages val
    end

    def revision val, **options
      latest.revision val, options
    end

    def create_option_helpers name, spec
      option_spec = self.send(spec).options[name.to_sym]
      case option_spec.type
      when :boolean
        class_eval <<-EOT
          def self.#{name.to_s.gsub('-', '_')}?
            #{spec}.options[:'#{name}'].value || #{spec}.options[:'#{name}'].default
          end
          def #{name.to_s.gsub('-', '_')}?
            #{spec}.options[:'#{name}'].value || #{spec}.options[:'#{name}'].default
          end
        EOT
      when :package
        if name =~ /^use-/
          class_eval <<-EOT
            def self.#{name.to_s.gsub('use-', '')}
              #{spec}.options[:'#{name}'].value || #{spec}.options[:'#{name}'].default
            end
            def #{name.to_s.gsub('use-', '')}
              #{spec}.options[:'#{name}'].value || #{spec}.options[:'#{name}'].default
            end
          EOT
        else
          CLI.report_error "When package option is a package, the option name should be 'use_*'!"
        end
      else
        CLI.report_error "Package option #{CLI.red name} is invalid!"
      end
    end

    def option val, **options
      latest.option val, options
      # Only allow latest spec can have options.
      create_option_helpers val, :latest
    end

    def depends_on val, **options
      latest.depends_on val, options
    end

    def latest
      eval "@@#{package_name}_latest ||= PackageSpec.new"
    end

    # To support multiple versions of package, but the history versions should
    # be limited.
    def history &block
      eval "@@#{package_name}_history ||= {}"
      return eval "@@#{package_name}_history" if not block_given?
      spec = PackageSpec.new
      spec.instance_eval(&block)
      eval "@@#{package_name}_history[spec.version.to_s] = spec"
    end
  end
end
