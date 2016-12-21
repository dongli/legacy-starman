module STARMAN
  class Libxml2 < Package
    homepage 'http://xmlsoft.org'
    url 'http://xmlsoft.org/sources/libxml2-2.9.4.tar.gz'
    sha256 'ffb911191e509b966deb55de705387f14156e1a56b21824357cdf0053233633c'
    version '2.9.4'

    depends_on :zlib

    def install
      args = %W[
        --prefix=#{prefix}
        --disable-dependency-tracking
        --without-python
        --without-lzma
        --with-zlib=#{Zlib.prefix}
      ]
      run './configure', *args
      run 'make'
      run 'make', 'install'
    end
  end
end
