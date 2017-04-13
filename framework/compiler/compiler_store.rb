module STARMAN
  class CompilerStore
    LanguageCompilerVariableNames = {
      c: 'CC',
      cxx: 'CXX',
      fortran: ['FC', 'F77']
    }.freeze
    LanguageCompilerFlagNames = {
      c: 'CFLAGS',
      cxx: 'CXXFLAGS',
      fortran: ['FFLAGS', 'FCFLAGS']
    }.freeze

    class << self
      def set_compiler_sets command_hash_array
        @@compiler_sets = []
        command_hash_array.each do |command_hash|
          @@compiler_sets << CompilerSet.new(command_hash)
        end
      end

      def set_active_compiler_set compiler_set_index
        if compiler_set_index >= @@compiler_sets.size
          CLI.report_error "Your default compiler set does not exist! Configure again!"
        end
        @@active_compiler_set_index = compiler_set_index
        @@active_compiler_set = @@compiler_sets[compiler_set_index]
        @@active_compiler_set.compilers.each do |language, compiler|
          System::Shell.set LanguageCompilerVariableNames[language], compiler.languages[language][:command] rescue nil
        end
      end

      def compiler_sets
        @@compiler_sets ||= []
      end

      def active_compiler_set_index
        @@active_compiler_set_index ||= 0
      end

      def active_compiler_set
        @@active_compiler_set ||= nil
      end

      def compiler language
        @@active_compiler_set.compiler language
      end

      def export_env
        case CompilerStore.compiler(:c).vendor
        when :intel
          bin = Pathname.new(CompilerStore.compiler(:c).command).dirname
          # Look for iccvars.sh.
          while true
            if bin.entries.index { |x| x.to_s == 'iccvars.sh' }
              library_path = `source #{bin}/iccvars.sh intel64 && env`.match(/^#{OS.ld_library_path}=(.*)/)[1] rescue nil
              System::Shell.prepend OS.ld_library_path, library_path, separator: ':' if library_path and not library_path.empty?
              break
            end
            bin = bin.dirname
          end
        when :gnu
          # If compiler is GNU installed by STARMAN, export some environment variables for it.
          Gcc.new.export_env if CompilerStore.compiler(:c).command.to_s.include? Gcc.bin
        end
        case (CompilerStore.compiler(:fortran).vendor rescue nil)
        when :intel
          bin = Pathname.new(CompilerStore.compiler(:fortran).command).dirname
          # Look for ifortvars.sh.
          while true
            if bin.entries.index { |x| x.to_s == 'ifortvars.sh' }
              library_path = `source #{bin}/ifortvars.sh intel64 && env`.match(/^#{OS.ld_library_path}=(.*)/)[1] rescue nil
              System::Shell.prepend OS.ld_library_path, library_path, separator: ':' if library_path and not library_path.empty?
              break
            end
            bin = bin.dirname
          end
        when :gnu
        end
        # Check if there is any library_path set in config file.
        library_path = ConfigStore.send(:"compiler_set_#{@@active_compiler_set_index}")[:library_path]
        System::Shell.prepend OS.ld_library_path, library_path, separator: ':' if library_path and not library_path.empty?
      end

      def set_default_flags
        return unless @@active_compiler_set
        LanguageCompilerFlagNames.each do |language, flag_names|
          Array(flag_names).each do |flag_name|
            compiler = CompilerStore.compiler(language)
            next if not compiler
            flags = [compiler.default_flags]
            flags << compiler.flag(:pic)
            System::Shell.set flag_name, flags.join(' ')
          end
        end
      end

      def unset_flags
        return unless @@active_compiler_set
        LanguageCompilerFlagNames.each do |language, flags|
          Array(flags).each do |flag|
            System::Shell.set flag, ''
          end
        end
        System::Shell.set 'LDFLAGS', ''
      end

      def set_optimization_flags level
        LanguageCompilerFlagNames.each do |language, flags|
          Array(flags).each do |flag|
            System::Shell.append flag, "-O#{level}"
          end
        end
      end

      def no_optimization
        LanguageCompilerFlagNames.each do |language, flags|
          Array(flags).each do |flag|

            System::Shell.set flag, '-w -pipe'
          end
        end
      end
    end
  end
end
