module STARMAN
  module PackageDSL
    def self.included base
      base.extend self
    end

    [:homepage, :url, :mirror, :sha256, :version, :filename, :group_master].each do |attr|
      class_eval <<-EOT
        def #{attr} val = nil
          latest.#{attr} val
        end
      EOT
    end

    [:label, :has_label?, :language].each do |attr|
      class_eval <<-EOT
        def #{attr} *val
          latest.#{attr} *val
        end
      EOT
    end

    [:languages, :options].each do |attr|
      class_eval <<-EOT
        def #{attr}
          latest.#{attr}
        end
      EOT
    end

    def revision val = nil, options = {}
      latest.revision val, options
    end

    def belongs_to val
      latest.group_master val
    end

    def create_option_helpers name, spec
      option_spec = self.send(spec).options[name.to_sym]
      case option_spec.type
      when :boolean
        class_eval <<-EOT
          def self.#{name.to_s.gsub('-', '_')}?
            #{spec}.options[:'#{name}'].value
          end
          def #{name.to_s.gsub('-', '_')}?
            #{spec}.options[:'#{name}'].value
          end
        EOT
      when :string
        class_eval <<-EOT
          def self.#{name.to_s.gsub('-', '_')}
            #{spec}.options[:'#{name}'].value
          end
          def #{name.to_s.gsub('-', '_')}
            #{spec}.options[:'#{name}'].value
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

    def option val, options = nil
      if options
        latest.option val, options
        # Only allow latest spec can have options.
        create_option_helpers val, :latest
      else
        latest.options[val.to_sym]
      end
    end

    def patch data = nil, &block
      if data == :DATA
        data = ''
        start = false
        File.open("#{ENV['STARMAN_ROOT']}/packages/#{self.name}.rb", 'r').each do |line|
          if line =~ /__END__/
            start = true
            next
          end
          data << line if start
        end
        latest.patch data
      else
        latest.patch &block
      end
    end

    def depends_on val, options = {}
      latest.depends_on val, options
    end

    def latest
      if eval "not defined? @@#{self.name}_latest"
        eval "@@#{self.name}_latest ||= PackageSpec.new"
        eval <<-EOT
          @@#{self.name}_latest.options.each do |option_name, option_options|
            create_option_helpers option_name, :latest
          end
        EOT
      end
      eval "@@#{self.name}_latest"
    end

    def resource tag, &block
      eval "@@#{self.name}_resources ||= {}"
      return eval "@@#{self.name}_resources[tag]" if not block_given?
      spec = PackageSpec.new
      spec.instance_eval(&block)
      eval "@@#{self.name}_resources[tag] = spec"
    end

    # To support external binaries of package.
    def external_binary_on *options, &block
      eval "@@#{self.name}_external_binary ||= {}"
      return eval "@@#{self.name}_external_binary" if not block_given?
      spec = PackageSpec.new
      spec.instance_eval(&block)
      eval "@@#{self.name}_external_binary[options.to_s] = spec"
    end

    # To support multiple versions of package, but the history versions should
    # be limited. TODO: Maybe put the history version into a separate file is a
    # good idea.
    def history &block
      eval "@@#{self.name}_history ||= {}"
      return eval "@@#{self.name}_history" if not block_given?
      spec = PackageSpec.new
      spec.instance_eval &block
      eval "@@#{self.name}_history[spec.version.to_s] = spec"
    end

    # Clean the internal data for reevaluating class definition, especially when
    # setting options like 'with-mpi' or 'with-cxx'.
    def clean package_name
      eval "@@#{package_name}_latest.clean if defined? @@#{package_name}_latest"
      eval <<-RUBY
        if defined? @@#{package_name}_history
          @@#{package_name}_history.each do |spec|
            spec.clean
          end
        end
      RUBY
      # Clean resources.
      eval "@@#{package_name}_resources = {}"
    end

    def external_binary_path
      "#{ConfigStore.package_root}/#{self.external_binary.filename}"
    end
  end
end
