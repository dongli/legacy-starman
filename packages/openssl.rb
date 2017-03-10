module STARMAN
  class Openssl < Package
    homepage 'https://openssl.org/'
    url 'https://www.openssl.org/source/openssl-1.1.0d.tar.gz'
    sha256 '7d5ebb9e89756545c156ff9c13cf2aa6214193b010a468a3bc789c3c28fe60df'
    version '1.1.0d'
    language :c

    label :system_conflict if OS.ubuntu?

    option 'x86-64', {
      desc: 'Build x86-64 library.',
      accept_value: { boolean: true }
    }

    depends_on :zlib

    resource :cert_file do
      url 'http://curl.haxx.se/ca/cacert.pem'
      sha256 'e62a07e61e5870effa81b430e1900778943c228bd7da1259dd6a955ee2262b47'
      filename 'cert.pem'
    end

    def arch_flags
      if OS.mac?
        { x86_64: 'darwin64-x86_64-cc', i386: 'darwin-i386-cc' }
      elsif OS.linux?
        { x86_64: 'linux-x86_64', i386: 'linux-x32' }
      end
    end

    def install
      args = %W[
        --prefix=#{prefix}
        --openssldir=#{etc}/openssl
        zlib-dynamic
        shared
        enable-cms
      ]
      args << 'enable-ec_nistp_64_gcc_128' # Needs C compiler to support __uint128_t.
      inreplace 'crypto/comp/c_zlib.c',
        'zlib_dso = DSO_load(NULL, LIBZ, NULL, 0);',
        "zlib_dso = DSO_load(NULL, \"#{Zlib.lib}/libz.#{OS.soname}\", NULL, DSO_FLAG_NO_NAME_TRANSLATION);"
      run './Configure', *args, arch_flags[x86_64? ? :x86_64 : :i386]
      inreplace 'Makefile', {
        /^CFLAGS=/ => "CFLAGS=-I#{Zlib.inc} ",
        /^LDFLAGS=/ => "LDFLAGS=-L#{Zlib.lib} "
      }
      run 'make'
      run 'make', 'test' unless skip_test?
      run 'make', 'install'
    end

    def post_install
      mkdir_p "#{etc}/openssl"
      if OS.mac?
        valid_certs = []
        keychains = %w[
          /System/Library/Keychains/SystemRootCertificates.keychain
        ]

        certs_list = `security find-certificate -a -p #{keychains.join(" ")}`
        certs = certs_list.scan(
          /-----BEGIN CERTIFICATE-----.*?-----END CERTIFICATE-----/m
        )

        valid_certs = certs.select do |cert|
          IO.popen("#{bin}/openssl x509 -inform pem -checkend 0 -noout", "w") do |openssl_io|
            openssl_io.write(cert)
            openssl_io.close_write
          end
          $?.success?
        end
        write_file "#{etc}/openssl/cert.pem", valid_certs.join("\n")
      else
        cp resource(:cert_file).path, "#{etc}/openssl/"
      end
    end
  end
end
