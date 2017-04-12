module STARMAN
  class Cnvgrib < Package
    url 'http://www.nco.ncep.noaa.gov/pmb/codes/GRIB2/cnvgrib-1.4.1.tar'
    sha256 '7aaf5540f5fd4dc032cc58a2ccfabe65227f89c89626931f4b31511823cdf04d'
    version '1.4.1'
    language :fortran

    depends_on :g2lib
    depends_on :jasper
    depends_on :libpng
    depends_on :zlib
    depends_on :w3lib

    def install
      inreplace 'makefile', {
        /^FC = g95/ => "FC = #{CompilerStore.compiler(:fortran).command}",
        '-I /pub/share/ncoops/g2lib-1.2.2' => "-I#{G2lib.inc} -I#{Jasper.inc} -I#{Libpng.inc} -I#{Zlib.inc}",
        '-L/pub/share/ncoops/g2lib-1.2.2' => "-L#{G2lib.lib}",
        '-L/pub/share/ncoops/w3lib-2.0' => "-L#{W3lib.lib}",
        '-L/pub/share/ncoops/jasper-1.900.1/src/libjasper/.libs' => "-L#{Jasper.lib} -L#{Libpng.lib} -L#{Zlib.lib}"
      }
      run 'make'
      mkdir_p bin
      cp 'cnvgrib', bin
    end
  end
end
