module STARMAN
  class Bison < Package
    url 'http://ftp.gnu.org/gnu/bison/bison-3.0.4.tar.gz'
    sha256 'b67fd2daae7a64b5ba862c66c07c1addb9e6b1b05c5f2049392cfd8a2172952e'
    version '3.0.4'

    label :compiler_agnostic

    depends_on :m4
    depends_on :libiconv
    depends_on :gettext

    def install
      args = %W[
        --prefix=#{prefix}
        --disable-dependency-tracking
        --with-libiconv-prefix=#{Libiconv.prefix}
        --with-libintl-prefix=#{Gettext.prefix}
      ]
      run './configure', *args
      run 'make'
      run 'make', 'install'
    end
  end
end
