module STARMAN
  class ClangCompiler < Compiler
    vendor :llvm
    version do
      res = `clang -v 2>&1`.match(/Apple LLVM version ([^ ]+)/)
      CLI.report_error "Failed to query version of #{CLI.red 'clang'}!" if not res
      res[1]
    end
    language :c,   :command => 'clang',   :default_flags => '-O2'
    language :cxx, :command => 'clang++', :default_flags => '-O2'
    flag :openmp => '-fopenmp'
    flag :pic => '-fPIC'
    flag :libcxx => '-lc++'
    flag :cxx11 => '-std=c++11 -stdlib=libc++'
  end
end
