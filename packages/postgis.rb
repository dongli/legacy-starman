module STARMAN
  class Postgis < Package
    url 'http://download.osgeo.org/postgis/source/postgis-2.3.1.tar.gz'
    sha256 '4c8d6bda93cd4aa690e98b97d67334b55f37eb1df55df3c70a717433050ca275'
    version '2.3.1'

    label :compiler_agnostic
    label :parasite, into: :postgresql

    depends_on :gdal
    depends_on :geos
    depends_on :gettext
    depends_on :gpp if needs_build?
    depends_on :json_c
    depends_on :libiconv
    depends_on :libxml2
    depends_on :pkgconfig if needs_build?
    depends_on :postgresql
    depends_on :pcre
    depends_on :proj

    def install
      args = %W[
        --with-gdalconfig=#{Gdal.bin}/gdal-config
        --with-gettext=#{Gettext.prefix}
        --with-geosconfig=#{Geos.bin}/geos-config
        --with-libiconv=#{Libiconv.prefix}
        --with-projdir=#{Proj.prefix}
        --with-jsondir=#{Json_c.prefix}
        --with-pcredir=#{Pcre.prefix}
        --with-pgconfig=#{Postgresql.bin}/pg_config
        --with-xml2config=#{Libxml2.bin}/xml2-config
        --disable-nls
      ]
      run './configure', *args
      inreplace 'liblwgeom/Makefile', 'prefix = /usr/local', "prefix = #{Postgresql.prefix}"
      run 'make'
      run 'make', 'install'
    end
  end
end
