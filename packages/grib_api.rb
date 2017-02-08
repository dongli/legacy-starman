module STARMAN
  class Grib_api < Package
    url 'https://mirrors.ocf.berkeley.edu/debian/pool/main/g/grib-api/grib-api_1.19.0.orig.tar.xz'
    sha256 'c234a0a6d551a79ac77eae86b5effaa82c96dfc16ba6a8e7570067d83f1f6326'
    version '1.19.0'

    option 'with-fortran', {
      desc: 'Build Fortran bindings',
      accept_value: { boolean: true }
    }

    option 'with-netcdf', {
      desc: 'Enable netcdf encoding/decoding using netcdf library.',
      accept_value: { boolean: false }
    }

    option 'with-python', {
      desc: 'Enable the Python interface in the build.',
      accept_value: { boolean: true }
    }

    language :c
    language :fortran if with_fortran?

    depends_on :byacc if needs_build? and not OS.mac?
    depends_on :jasper
    depends_on :libpng
    depends_on :netcdf if with_netcdf?
    depends_on :zlib

    if with_python?
      depends_on :python3

      resource :pygrib do
        url 'https://github.com/jswhit/pygrib/archive/v2.0.2rel.tar.gz'
        sha256 '7e91608ddb01bf842e26764bcaa013d1d7e35c641ba4ab0b9d7f4272b581a43a'
        filename 'pygrib-2.0.2.tar.gz'
      end

      def export_env
        System::Shell.append 'PYTHONPATH', "#{prefix}/lib/python#{Python3.xy}/site-packages", separator: ':'
      end
    end

    def install
      # inreplace 'src/grib_jasper_encoding.c', 'image.inmem_    = 1;', ''
      args = %W[
        --prefix=#{prefix}
        --disable-dependency-tracking
        --with-jasper=#{Jasper.prefix}
        --with-png-support
        CPPFLAGS='-I#{Libpng.inc} -I#{Zlib.inc}'
        LDFLAGS='-L#{Libpng.lib} -L#{Zlib.lib}'
      ]
      args << '--disable-fortran' unless with_fortran?
      run './configure', *args
      run 'make', 'install'
      if with_python?
        run 'pip3', 'install', '--upgrade', 'numpy'
        run 'pip3', 'install', '--upgrade', 'pyproj'
        install_resource :pygrib, '.'
        work_in 'pygrib-2.0.2rel' do
          export_env
          mkdir_p "#{prefix}/lib/python#{Python3.xy}/site-packages"
          ENV['JASPER_DIR'] = Jasper.prefix
          ENV['PNG_DIR'] = Libpng.prefix
          ENV['ZLIB_DIR'] = Zlib.prefix
          ENV['GRIBAPI_DIR'] = prefix
          run 'python3', 'setup.py', 'install', "--prefix=#{prefix}"
        end
      end
    end
  end
end
