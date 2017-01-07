module STARMAN
  class Libgeotiff < Package
    url 'http://download.osgeo.org/geotiff/libgeotiff/libgeotiff-1.4.1.tar.gz'
    sha256 'acfc76ee19b3d41bb9c7e8b780ca55d413893a96c09f3b27bdb9b2573b41fd23'
    version '1.4.1'

    depends_on :libtiff
    depends_on :libjpeg
    depends_on :zlib
    depends_on :proj

    def install
      args = %W[
        --disable-dependency-tracking
        --prefix=#{prefix}
        --with-libtiff=#{Libtiff.prefix}
        --with-zlib=#{Zlib.prefix}
        --with-jpeg=#{Libjpeg.prefix}
      ]
      run './configure', *args
      run 'make'
      run 'make', 'install'
    end
  end
end
