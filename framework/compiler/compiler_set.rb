module STARMAN
  class CompilerSet
    include System::Command

    def initialize command_hash
      if command_hash.has_key? :installed_by_starman
        compiler_name = command_hash[:installed_by_starman]
        if not PackageLoader.has_package? compiler_name
          CLI.report_error "Unknown STARMAN installed compiler #{CLI.red compiler_name}!"
        end
      end
      @compilers = {}
      command_hash.each do |language, command|
        if language == :install_by_starman

          next
        end
        if language.to_s =~ /^mpi_(c|cxx|fortran)/
          actual_language = language.to_s.gsub('mpi_', '').to_sym
        else
          if not system_command? command
            CLI.report_warning "Compiler command #{CLI.red compiler_command} does not exist!"
            @compilers[language] = nil
          else
            @compilers[language] = Compiler.choose_spec language, command
          end
        end
      end
    end

    def compiler language
      @compilers ||= {}
      @compilers[language]
    end

    def compilers
      @compilers ||= {}
    end

    def tag
      res = ''
      @compilers.each do |language, compiler|
        res << "-#{compiler.tag language}"
      end
      res
    end
  end
end
