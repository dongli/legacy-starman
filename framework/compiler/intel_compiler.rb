module STARMAN
  class IntelCompiler < Compiler
    vendor :intel
    version do |command|
      res = `#{command} -v 2>&1`.match(/version (\d+\.\d+(\.\d+)?)/i)
      CLI.report_error "Failed to query version of #{CLI.red command}!" if not res
      res[1]
    end
    language :c,       :command => 'icc',   :default_flags => '-O2'
    language :cxx,     :command => 'icpc',  :default_flags => '-O2'
    language :fortran, :command => 'ifort', :default_flags => '-O2'
    flag :openmp => '-openmp'
    flag :pic => '-fPIC'
  end
end
