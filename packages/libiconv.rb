module STARMAN
  class Libiconv < Package
    homepage 'https://www.gnu.org/software/libiconv/'
    url 'http://ftpmirror.gnu.org/libiconv/libiconv-1.14.tar.gz'
    sha256 '72b24ded17d687193c3366d0ebe7cde1e6b18f0df8c55438ac95be39e8a30613'
    version '1.14'

    # Mac ships one with no 'lib' prefix in some symbols.
    label :system_conflict if OS.mac?

    def install
      args = %W[
        --prefix=#{prefix}
        --disable-debug
        --disable-dependency-tracking
        --enable-extra-encodings
      ]
      run './configure', *args
      run 'make'
      run 'make', 'install'
    end
  end
end
