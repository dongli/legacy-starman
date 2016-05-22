module STARMAN
  class CompilerStore
    LanguageCompilerVariableNames = {
      :c => 'CC',
      :cxx => 'CXX',
      :fortran => 'FC'
    }

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
          System::Bash.set LanguageCompilerVariableNames[language], compiler.languages[language][:command]
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
    end
  end
end
