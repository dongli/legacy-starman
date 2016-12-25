module STARMAN
  class Grib_api < Package
    url 'https://mirrors.ocf.berkeley.edu/debian/pool/main/g/grib-api/grib-api_1.19.0.orig.tar.xz'
    sha256 'c234a0a6d551a79ac77eae86b5effaa82c96dfc16ba6a8e7570067d83f1f6326'
    version '1.19.0'

    option 'with-fortran', {
      desc: 'Build Fortran bindings',
      accept_value: { boolean: false }
    }

    option 'with-netcdf', {
      desc: 'Enable netcdf encoding/decoding using netcdf library.',
      accept_value: { boolean: false }
    }

    option 'with-python', {
      desc: 'Enable the Python interface in the build.',
      accept_value: { boolean: false }
    }

    language :c
    language :fortran if with_fortran?

    depends_on :byacc if needs_build? and not OS.mac?
    depends_on :jasper
    depends_on :libpng
    depends_on :netcdf if with_netcdf?

    def install
      # inreplace 'src/grib_jasper_encoding.c', 'image.inmem_    = 1;', ''
      args = %W[
        --prefix=#{prefix}
        --disable-dependency-tracking
        --with-jasper=#{Jasper.prefix}
        --with-png-support
        CPPFLAGS='-I#{Libpng.inc}'
        LDFLAGS='-L#{Libpng.lib}'
      ]
      args << '--disable-fortran' unless with_fortran?
      args << '--enable-python' if with_python?
      run './configure', *args
      run 'make', 'install'
    end
  end
end
