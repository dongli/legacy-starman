module STARMAN
  class G2lib < Package
    url 'http://www.nco.ncep.noaa.gov/pmb/codes/GRIB2/g2lib-1.4.0.tar'
    sha256 '50ed657f7395377aa8de1097e62d5be68f48e90dc859766cffddb39a909cc7b3'
    version '1.4.0'

    depends_on :jasper
    depends_on :libpng

    def install
      inreplace 'makefile', {
        /INCDIR=.*$/ => "INCDIR=-I#{Jasper.inc} -I#{Libpng.inc}",
        /FC=.*$/ => "FC=#{CompilerStore.compiler(:fortran).command}",
        /CC=.*$/ => "CC=#{CompilerStore.compiler(:c).command}"
      }
      run 'make'
      mkdir_p inc
      mkdir_p lib
      cp '*.mod', inc
      cp '*.a', lib
    end
  end
end
