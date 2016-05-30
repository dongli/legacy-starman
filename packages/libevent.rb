module STARMAN
  class Libevent < Package
    homepage 'http://libevent.org'
    url 'https://github.com/libevent/libevent/releases/download/release-2.0.22-stable/libevent-2.0.22-stable.tar.gz'
    sha256 '71c2c49f0adadacfdbe6332a372c38cf9c8b7895bb73dabeaa53cdcc1d4e1fa3'
    version '2.0.22'

    depends_on :openssl

    def install
      args = %W[
        --prefix=#{prefix}
        --disable-dependency-tracking
        --disable-debug-mode
      ]
      run './configure', *args
      run 'make'
      run 'make', 'install'
    end
  end
end
