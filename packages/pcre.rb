module STARMAN
  class Pcre < Package
    homepage 'http://www.pcre.org/'
    url 'https://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-8.39.tar.bz2'
    sha256 'b858099f82483031ee02092711689e7245586ada49e534a06e678b8ea9549e8b'
    version '8.39'

    depends_on :bzip2
    depends_on :zlib

    def install
      args = %W[
        --disable-dependency-tracking
        --prefix=#{prefix}
        --enable-utf8
        --enable-pcre8
        --enable-pcre16
        --enable-pcre32
        --enable-unicode-properties
        --enable-pcregrep-libz
        --enable-pcregrep-libbz2
        --enable-jit
        CPPFLAGS='-I#{Bzip2.inc} -I#{Zlib.inc}'
        LDFLAGS='-L#{Bzip2.lib} -L#{Zlib.lib}'
      ]
      run './configure', *args
      run 'make'
      run 'make', 'test' if not skip_test?
      run 'make', 'install'
    end
  end
end
