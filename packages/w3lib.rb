module STARMAN
  class W3lib < Package
    url 'http://www.nco.ncep.noaa.gov/pmb/codes/GRIB2/w3lib-2.0.2.tar'
    sha256 '4e0481d0a9a50a024b40351fa475d1769af588910790c7c91ccf339e2d1a5472'
    version '2.0.2'
    language :c, :fortran

    def install
      inreplace 'Makefile', {
        'F77     = g95' => "F77 = #{CompilerStore.compiler(:fortran).command}",
        'CC      = cc' => "CC = #{CompilerStore.compiler(:c).command}"
      }
      inreplace 'bacio.v1.3.c', 'malloc.h', 'sys/malloc.h' if OS.mac?
      run 'make'
      mkdir_p lib
      cp 'libw3.a', lib
    end
  end
end
