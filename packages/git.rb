module STARMAN
  class Git < Package
    url 'https://www.kernel.org/pub/software/scm/git/git-2.12.0.tar.xz'
    sha256 '1821766479062d052cc1897d0ded95212e81e5c7f1039786bc4aec2225a32027'
    version '2.12.0'

    depends_on :curl
    depends_on :expat
    depends_on :gettext
    depends_on :openssl
    depends_on :pcre
    depends_on :zlib

    def install
      args = %W[
        prefix=#{prefix}
        sysconfdir=#{etc}
        NO_FINK=1
        NO_DARWIN_PORTS=1
        V=1
        NO_R_TO_GCC_LINKER=1
        BLK_SHA1=1
        NO_PERL=1
        GETTEXT=1
        CURLDIR=#{Curl.prefix}
        OPENSSLDIR=#{Openssl.prefix}
        ZLIB_PATH=#{Zlib.prefix}
        USE_LIBPCRE=1
        LIBPCREDIR=#{Pcre.prefix}
        CC=${CC}
        CFLAGS="${CFLAGS}"
        CPPFLAGS="${CPPFLAGS}"
        LDFLAGS="${LDFLAGS} -lintl"
      ]
      run 'make', 'install', *args
    end
  end
end
