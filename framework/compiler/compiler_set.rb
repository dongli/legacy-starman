module STARMAN
  class CompilerSet
    include System::Command

    def initialize command_hash
      @compilers = {}
      command_hash.each do |language, command|
        if [:c, :cxx, :fortran].include? language
          if not system_command? command
            CLI.report_warning "Compiler command #{CLI.red command} does not exist!"
            @compilers[language] = nil
          else
            @compilers[language] = Compiler.choose_spec language, full_command_path(command)
          end
        end
      end
    end

    def set_mpi_wrappers command_hash
      # Handle MPI wrapper commands.
      command_hash.each do |language, command|
        if language.to_s =~ /^mpi_(c|cxx|fortran)/
          actual_language = language.to_s.gsub('mpi_', '').to_sym
          @compilers[actual_language].mpi = Pathname.new full_command_path(command)
        end
      end
      # If user does not set MPI wrappers, try to use default ones.
      if ConfigStore.defaults[:mpi]
        PackageLoader.load_package ConfigStore.defaults[:mpi].to_sym, not_record: true
        mpi = Object.const_get("STARMAN::#{ConfigStore.defaults[:mpi].capitalize}").new
        mpi.shipped_wrappers.each do |language, command|
          (@compilers[language].mpi = Pathname.new full_command_path(command)) rescue nil
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
