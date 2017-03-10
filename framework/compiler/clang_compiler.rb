module STARMAN
  class ClangCompiler < Compiler
    vendor :llvm
    version do |command|
      res = `#{command} -v 2>&1`.match(/Apple LLVM version ([^ ]+)/)
      CLI.report_error "Failed to query version of #{CLI.red 'clang'}!" if not res
      res[1]
    end
    language :c,   command: 'clang',   default_flags: '-O2'
    language :cxx, command: 'clang++', default_flags: '-O2'
    flag :openmp => nil
    flag :pic => '-fPIC'
    flag :libcxx => '-stdlib=libc++'
    flag :cxx11 => '-std=c++11'
    feature :openmp do
      false
    end
  end
end
