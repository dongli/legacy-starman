module STARMAN
  class Gdal < Package
    url 'http://download.osgeo.org/gdal/1.11.5/gdal-1.11.5.tar.gz'
    sha256 '49f99971182864abed9ac42de10545a92392d88f7dbcfdb11afe449a7eb754fe'
    version '1.11.5'

    option :'with-more-drivers', {
      desc: 'Build more drivers.',
      accept_value: { boolean: false }
    }
    option :'with-libkml', {
      desc: "Build with Google's libkml driver (requires libkml --HEAD or >= 1.3).",
      accept_value: { boolean: false }
    }

    depends_on :armadillo
    depends_on :curl
    depends_on :expat
    depends_on :freexl
    depends_on :geos
    depends_on :giflib
    depends_on :jasper
    depends_on :json_c
    depends_on :libiconv
    depends_on :libjpeg
    depends_on :libpng
    depends_on :libtiff
    depends_on :libgeotiff
    depends_on :libxml2
    depends_on :pcre
    depends_on :postgresql
    depends_on :proj
    depends_on :zlib

    def install
      inreplace 'frmts/jpeg2000/jpeg2000_vsil_io.cpp',
        'stream->bufbase_ = JAS_CAST(uchar *, buf);',
        'stream->bufbase_ = JAS_CAST(u_char *, buf);'
      # Fix hardcoded mandir: https://trac.osgeo.org/gdal/ticket/5092
      inreplace 'configure', %r[^mandir='\$\{prefix\}/man'$], ''

      args = %W[
        --prefix=#{prefix}
        --mandir=#{man}
        --disable-debug
        --with-local=#{prefix}
        --with-threads
        --with-libtool
        --with-pcraster=internal
        --with-pcidsk=internal
        --with-bsb
        --with-grib
        --with-pam
        --with-libiconv-prefix=#{Libiconv.prefix}
        --with-libz=#{Zlib.prefix}
        --with-png=#{Libpng.prefix}
        --with-expat=#{Expat.prefix}
        --with-curl=#{Curl.bin}/curl-config
        --with-jpeg=#{Libjpeg.prefix}
        --without-jpeg2
        --with-gif=#{Giflib.prefix}
        --with-libtiff=#{Libtiff.prefix}
        --with-geotiff=#{Libgeotiff.prefix}
        --with-freexl=#{Freexl.prefix}
        --with-geos=#{Geos.prefix}
        --with-static-proj4=#{Proj.prefix}
        --with-libjson-c=#{Json_c.prefix}
        --without-grass
        --without-libgrass
        --with-pg=#{Postgresql.bin}/pg_config
        --without-mysql
        --without-python
        --without-perl
        --without-php
        --without-ruby
        --with-armadillo=#{Armadillo.prefix}
      ]

      run './configure', *args
      run 'make'
      run 'make', 'install'
      run 'make', 'install-man'
    end
  end
end
