module STARMAN
  class Autoconf < Package
    homepage 'https://www.gnu.org/software/autoconf'
    url 'https://ftpmirror.gnu.org/autoconf/autoconf-2.69.tar.gz'
    sha256 '954bd69b391edc12d6a4a51a2dd1476543da5c6bbf05a95b59dc0dd6fd4c2969'
    version '2.69'

    label :compiler_agnostic
    label :system_first, command: 'autoconf'

    depends_on :libtool

    def install
      inreplace 'bin/autoreconf.in', 'libtoolize', 'glibtoolize'
      inreplace 'man/autoreconf.1', 'libtoolize', 'glibtoolize'

      args = %W[
        --prefix=#{prefix}
        --with-lispdir=#{share}/emacs/site-lisp/autoconf
      ]

      run './configure', *args
      run 'make', 'install'
    end
  end
end
