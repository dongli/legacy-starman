module STARMAN
  class Ncurses < Package
    url 'https://ftpmirror.gnu.org/ncurses/ncurses-6.0.tar.gz'
    sha256 'f551c24b30ce8bfb6e96d9f59b42fbea30fa3a6123384172f9e7284bcf647260'
    version '6.0'

    def install
      args = %W[
        --prefix=#{prefix}
        --enable-pc-files
        --enable-sigwinch
        --enable-symlinks
        --enable-widec
        --with-manpage-format=normal
        --with-shared
        --with-gpm=no
      ]
      run './configure', *args
      run 'make'
      run 'make', 'install'
    end
  end
end
