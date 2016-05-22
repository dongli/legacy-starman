module STARMAN
  class IntelCompiler < Compiler
    vendor :intel
    language :c,       :command => 'icc',   :default_flags => '-O2 -fPIC'
    language :cxx,     :command => 'icpc',  :default_flags => '-O2 -fPIC'
    language :fortran, :command => 'ifort', :default_flags => '-O2 -fPIC'
    flag :openmp => '-openmp'
    flag :pic => '-fPIC'
  end
end
