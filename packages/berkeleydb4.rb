module STARMAN
  class Berkeleydb4 < Package
    homepage 'https://www.oracle.com/technology/products/berkeley-db/index.html'
    url 'http://download.oracle.com/berkeley-db/db-4.8.30.tar.gz'
    sha256 'e0491a07cdb21fb9aa82773bbbedaeb7639cbd0e7f96147ab46141e0045db72a'
    version '4.8.30'

    label :compiler_agnostic

    def install
      args = %W[
        --prefix=#{prefix}
        --disable-debug
        --enable-cxx
      ]
      work_in 'build_unix' do
        run '../dist/configure', *args
        run 'make', 'install'
      end
    end
  end
end
