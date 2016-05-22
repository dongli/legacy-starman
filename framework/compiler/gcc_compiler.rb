module STARMAN
  class GccCompiler < Compiler
    vendor :gnu
    language :c,       :command => 'gcc',      :default_flags => '-O2 -fPIC'
    language :cxx,     :command => 'g++',      :default_flags => '-O2 -fPIC'
    language :fortran, :command => 'gfortran', :default_flags => '-O2 -fPIC'
    flag :openmp => '-fopenmp'
    flag :pic => '-fPIC'
    flag :libcxx => '-lstdc++'
  end
end
