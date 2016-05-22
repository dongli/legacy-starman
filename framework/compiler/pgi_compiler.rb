module STARMAN
  class PgiCompiler < Compiler
    vendor :pgi
    language :c,       :command => 'pgcc',                 :default_flags => '-O2 -fPIC'
    language :cxx,     :command => 'pgcpp',                :default_flags => '-O2 -fPIC'
    language :fortran, :command => ['pgfortran', 'pgf90'], :default_flags => '-O2 -fPIC'
    flag :openmp => '-openmp'
    flag :pic => '-fPIC'
  end
end
