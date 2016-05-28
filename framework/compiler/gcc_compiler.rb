module STARMAN
  class GccCompiler < Compiler
    vendor :gnu
    version do
      res = `#{spec.languages[:c][:command]} -v 2>&1`.match(/gcc \W+ (\d+\.\d+\.\d+)/)
      CLI.report_error "Failed to query version of #{CLI.red "#{spec.languages[:c][:command]}"}!" if not res
      res[1]
    end
    language :c,       :command => 'gcc',      :default_flags => '-O2 -fPIC'
    language :cxx,     :command => 'g++',      :default_flags => '-O2 -fPIC'
    language :fortran, :command => 'gfortran', :default_flags => '-O2 -fPIC'
    flag :openmp => '-fopenmp'
    flag :pic => '-fPIC'
    flag :libcxx => '-lstdc++'
    flag :cxx11 => '-std=c++11'
  end
end
