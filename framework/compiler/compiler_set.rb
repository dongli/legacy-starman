module STARMAN
  class CompilerSet
    include System::Command

    def initialize command_hash
      @compilers = {}
      command_hash.each do |language, command|
        next if [:library_path].include? language
        if language.to_s =~ /^mpi_(c|cxx|fortran)/
          actual_language = language.to_s.gsub('mpi_', '').to_sym
        else
          if not system_command? command
            CLI.report_warning "Compiler command #{CLI.red command} does not exist!"
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
