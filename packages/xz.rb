module STARMAN
  class Xz < Package
    homepage 'http://tukaani.org/xz/'
    url 'https://fossies.org/linux/misc/xz-5.2.2.tar.gz'
    sha256 '73df4d5d34f0468bd57d09f2d8af363e95ed6cc3a4a86129d2f2c366259902a2'
    version '5.2.2'

    label :compiler_agnostic
    label :system_first, command: 'xz'

    def install
      args = %W[
        --prefix=#{prefix}
        --disable-debug
        --disable-dependency-tracking
        --disable-silent-rules
      ]
      run './configure', *args
      run 'make', 'install'
    end
  end
end
