module STARMAN
  class Termcap < Package
    url 'https://ftp.gnu.org/gnu/termcap/termcap-1.3.1.tar.gz'
    sha256 '91a0e22e5387ca4467b5bcb18edf1c51b930262fd466d5fda396dd9d26719100'
    version '1.3.1'

    def install
      inreplace 'Makefile.in', 'CFLAGS = -g' => 'CFLAGS = -g -fPIC'
      run './configure', "--prefix=#{prefix}"
      run 'make'
      run 'make', 'install'
    end
  end
end
