module STARMAN
  class PgiCompiler < Compiler
    vendor :pgi
    version do |command|
      res = `#{command} -V 2>&1`.match(/ (\d+\.\d+(-\d+)?)/i)
      CLI.report_error "Failed to query version of #{CLI.red command}!" if not res
      res[1]
    end
    language :c,       :command => 'pgcc',                 :default_flags => '-O2 -fPIC'
    language :cxx,     :command => ['pgcpp', 'pgCC'],      :default_flags => '-O2 -fPIC'
    language :fortran, :command => ['pgfortran', 'pgf90'], :default_flags => '-O2 -fPIC'
    flag :openmp => '-openmp'
    flag :pic => '-fPIC'
  end
end
