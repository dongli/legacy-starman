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
        @@active_compiler_set_index = compiler_set_index
        @@active_compiler_set = @@compiler_sets[compiler_set_index]
        @@active_compiler_set.compilers.each do |language, compiler|
          System::Shell.set LanguageCompilerVariableNames[language], compiler.languages[language][:command]
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

      def set_default_flags
        LanguageCompilerFlagNames.each do |language, flags|
          Array(flags).each do |flag|
            System::Shell.set flag, CompilerStore.compiler(language).default_flags
          end
        end
      end

      def unset_flags
        LanguageCompilerFlagNames.each do |language, flags|
          Array(flags).each do |flag|
            System::Shell.set flag, ''
          end
        end
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
