module STARMAN
  module DirtyWorks
    def self.handle_absent_compiler packages
      return if CommandLine.command == :config
      ################################################################################
      # The following codes are really mess! They are just used to handle edge cases.
      # Change command line and package options that set build language bindings.
      [:c, :cxx, :fortran].each do |language|
        next if CompilerStore.compiler(language)
        packages.each_value do |package|
          next unless package
          if package.languages == [language]
            # The package only provides bindings in this language, we should exclude it.
            packages.each_value do |other_package|
              next if other_package == package
              other_package.dependencies.delete(package.name)
              other_package.slaves.delete(package)
            end
            packages.delete package.name
            if CommandLine.command == :install
              CLI.report_warning "Package #{CLI.red package.name} cannot be installed due to no #{language} compiler."
            end
          end
          next if not package.options[:"with-#{language}"]
          if package.options[:"with-#{language}"].extra[:need_compiler] != false
            package.options[:"with-#{language}"].check 'false'
          end
        end
        next if not CommandLine.options[:"with-#{language}"]
        CommandLine.options[:"with-#{language}"].check 'false'
      end
      ################################################################################
    end

    def self.remove_slave_packages packages
      packages.each do |name, package|
        next if not package.group_master
        packages.delete name
      end
    end
  end
end
