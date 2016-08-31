module STARMAN
  class Curl < Package
    homepage 'https://curl.haxx.se/'
    url 'https://curl.haxx.se/download/curl-7.50.1.tar.bz2'
    sha256 '3c12c5f54ccaa1d40abc65d672107dcc75d3e1fcb38c267484334280096e5156'
    version '7.50.1'
    language :c

    option 'with-libidn', {
      desc: 'Build with support for Internationalized Domain Names.',
      accept_value: { boolean: false }
    }
    option 'with-librtmp', {
      desc: 'Build with RTMP support.',
      accept_value: { boolean: false }
    }
    option 'with-libssh2', {
      desc: 'Build with scp and sftp support.',
      accept_value: { boolean: false }
    }
    option 'with-c-ares', {
      desc: 'Build with C-Ares async DNS support.',
      accept_value: { boolean: false }
    }
    option 'with-gssapi', {
      desc: 'Build with GSSAPI/Kerberos authentication support.',
      accept_value: { boolean: false }
    }
    option 'with-libmetalink', {
      desc: 'Build with libmetalink support.',
      accept_value: { boolean: false }
    }
    option 'with-nghttp2', {
      desc: 'Build with HTTP/2 support.',
      accept_value: { boolean: false }
    }

    depends_on :openssl

    def install
      args = %W[
        --disable-debug
        --disable-dependency-tracking
        --disable-silent-rules
        --prefix=#{prefix}
        --with-ssl=#{Openssl.prefix}
        --with-ca-bundle=#{Openssl.etc}/openssl/cert.pem
      ]
      args << "--with-libidn=#{Libidn.prefix}" if with_libidn?
      args << "--with-librtmp=#{Librtmp.prefix}" if with_librtmp?
      args << "--with-libssh2=#{Libssh2.prefix}" if with_libssh2?
      args << "--enable-ares=#{C_Ares.prefix}" if with_c_ares?
      args << "--with-gssapi=#{Gssapi.prefix}" if with_gssapi?
      args << "--with-libmetalink=#{Libmetalink.prefix}" if with_libmetalink?
      args << "--with-nghttp2=#{Nghttp2.prefix}" if with_nghttp2?
      run './configure', *args
      run 'make', 'install'
    end
  end
end
