module STARMAN
  module PackageDSL
    def self.included base
      base.extend self
    end

    [:homepage, :url, :mirror, :sha256, :version].each do |attr|
      class_eval <<-EOT
        def #{attr} val
          latest.#{attr} val
        end
      EOT
    end

    def create_option_helpers name, spec
      option = self.send(spec).options[name]
      if option[:accept_value].class == Symbol
        accept_values = [opton[:accept_value]]
      else
        accept_values = option[:accept_value]
      end
      accept_values.each_key do |value_type|
        case value_type
        when :boolean
          class_eval <<-EOT
            def self.#{name}?
              #{spec}.options[:#{name}][:value] || #{spec}.options[:#{name}][:accept_value][:#{value_type}]
            end
            def #{name}?
              #{spec}.options[:#{name}][:value] || #{spec}.options[:#{name}][:accept_value][:#{value_type}]
            end
          EOT
        when :package
          if name =~ /^use_/
            class_eval <<-EOT
              def self.#{name.to_s.gsub('use_', '')}
                #{spec}.options[:#{name}][:value] || #{spec}.options[:#{name}][:accept_value][:#{value_type}]
              end
              def #{name.to_s.gsub('use_', '')}
                #{spec}.options[:#{name}][:value] || #{spec}.options[:#{name}][:accept_value][:#{value_type}]
              end
            EOT
          else
            CLI.report_error "When package option is a package, the option name should be 'use_*'!"
          end
        else
          CLI.report_error "Package option #{CLI.red name} is invalid!"
        end
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
      eval "@@#{self.name.split('::').last}_latest ||= PackageSpec.new"
    end

    # To support multiple versions of package, but the history versions should
    # be limited.
    def history &block
      name = self.name.split('::').last
      eval "@@#{name}_history ||= {}"
      return eval "@@#{name}_history" if not block_given?
      spec = PackageSpec.new
      spec.instance_eval(&block)
      eval "@@#{name}_history[spec.version.to_s] = spec"
    end
  end
end
