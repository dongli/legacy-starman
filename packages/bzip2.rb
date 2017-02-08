module STARMAN
  class Bzip2 < Package
    homepage 'http://www.bzip.org/'
    url 'http://www.bzip.org/1.0.6/bzip2-1.0.6.tar.gz'
    sha256 'a2848f34fcd5d6cf47def00461fcb528a0484d8edef8208d6d2e2909dc61d9cd'
    version '1.0.6'

    def install
      inreplace 'Makefile', {
        '$(PREFIX)/man' => '$(PREFIX)/share/man',
        'CFLAGS=' => "CFLAGS=-fPIC "
      }
      run 'make', 'install', "PREFIX=#{prefix}"
    end
  end
end
