module STARMAN
  class Hdf4 < Package
    url 'http://www.hdfgroup.org/ftp/HDF/releases/HDF4.2.11/src/hdf-4.2.11.tar.bz2'
    sha256 'bb0e900b8cc6bc89a5730abc97e654e7705e8e1fbc4e0d4477f417822428d99b'
    version '4.2.11'

    depends_on :byacc if needs_build?
    depends_on :flex if needs_build?
    depends_on :libjpeg
    depends_on :szip
    depends_on :zlib

    def install
      # Note: We can not enable shared and fortran simultaneously.
      # => configure:5994: error: Cannot build shared fortran libraries. Please configure with --disable-fortran flag.
      args = %W[
        --prefix=#{prefix}
        --with-zlib=#{Zlib.prefix}
        --with-jpeg=#{Libjpeg.prefix}
        --with-szlib=#{Szip.prefix}
        --disable-netcdf
        --enable-fortran
        --enable-static
      ]
      args << '--disable-fortran' unless CompilerStore.compiler(:fortran)
      run './configure', *args
      run 'make', 'install'
    end
  end
end
