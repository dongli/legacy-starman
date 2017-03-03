module STARMAN
  class Libevent < Package
    homepage 'http://libevent.org'
    url 'https://github.com/libevent/libevent/archive/release-2.1.8-stable.tar.gz'
    sha256 '316ddb401745ac5d222d7c529ef1eada12f58f6376a66c1118eee803cb70f83d'
    version '2.1.8'

    depends_on :openssl

    def install
      args = %W[
        --prefix=#{prefix}
        --disable-dependency-tracking
        --disable-debug-mode
      ]
      run './autogen.sh'
      run './configure', *args
      run 'make'
      run 'make', 'install'
    end
  end
end
