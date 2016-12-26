module STARMAN
  class Met < Package
    url 'http://www.dtcenter.org/met/users/downloads/MET_releases/met-5.2.20160815.tar.gz'
    sha256 'f2d0178f1e6081080b6beebdf9915096635365069aeed8d62bcefbfe0f35b36a'
    version '5.2'
    language :c, :cxx, :fortran

    label :compiler_agnostic

    resource :patches do
      url 'http://www.dtcenter.org/met/users/support/known_issues/METv5.2/patches/met-5.2_patches_20161010.tar.gz'
      sha256 'a5aadcca21163cf10d5feb412c7883936214c6307afd9a83952762472bd156f1'
    end

    # FIXME: Don't know how to use the following bugfix.
    resource :bugfix do
      url 'http://www.dtcenter.org/met/users/downloads/MET_releases/met-5.2_bugfix.20161010.tar.gz'
      sha256 '7fadbf3051c69be1cefaabff1cb627f9d4cd68408881e0152be74ab86f249843'
    end

    depends_on :bufrlib
    depends_on :byacc if needs_build?
    depends_on :g2clib
    depends_on :gsl
    depends_on :hdf4
    depends_on :hdf_eos2
    depends_on :netcdf, 'with-legacy-cxx' => true
    depends_on :zlib

    def install
      decompress resource(:patches).path
      inreplace 'src/basic/vx_config/config_util.cc', {
        '#include <sys/types.h>' => "#include <sys/syslimits.h>\n#include <sys/types.h>"
      }
      args = %W[
        --prefix=#{prefix}
        --disable-dependency-tracking
        --enable-grib2
        MET_NETCDF=#{Netcdf.prefix}
        MET_GRIB2C=#{G2clib.prefix}
        MET_GSL=#{Gsl.prefix}
        MET_BUFRLIB=#{Bufrlib.lib}
        MET_HDF=#{Hdf4.prefix}
        MET_HDFEOS=#{Hdf_eos2.prefix}
        LDFLAGS='-L#{Jasper.lib} -L#{Libpng.lib} -L#{Zlib.lib}'
      ]
      args << '--disable-mode_graphics' # This needs cairo and freetype.
      run './configure', *args
      run 'make', 'install'
    end
  end
end
