module STARMAN
  class Wget < Package
    url 'https://ftpmirror.gnu.org/wget/wget-1.18.tar.xz'
    sha256 'b5b55b75726c04c06fe253daec9329a6f1a3c0c1878e3ea76ebfebc139ea9cc1'
    version '1.18'

    label :compiler_agnostic

    depends_on :pkgconfig if needs_build?
    depends_on :openssl
    depends_on :libidn
    depends_on :pcre
    depends_on :libmetalink
    depends_on :gpgme

    def install
      args = %W[
        --prefix=#{prefix}
        --with-ssl=openssl
        --with-libssl-prefix=#{Openssl.prefix}
        --disable-debug
      ]
      run './configure', *args
      run 'make', 'install'
    end
  end
end
