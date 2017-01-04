module STARMAN
  class Libtool < Package
    homepage 'https://www.gnu.org/software/libtool/'
    url 'https://ftpmirror.gnu.org/libtool/libtool-2.4.6.tar.xz'
    sha256 '7c87a8c2c8c0fc9cd5019e402bed4292462d00a718a7cd5f11218153bf28b26f'
    version '2.4.6'

    label :compiler_agnostic

    depends_on :m4

    def install
      args = %W[
        --prefix=#{prefix}
        --disable-dependency-tracking
        --program-prefix=g
        --enable-ltdl-install
      ]
      run './configure', *args
      run 'make', 'install'
    end
  end
end
