module STARMAN
  class Automake < Package
    homepage 'https://www.gnu.org/software/automake/'
    url 'https://ftpmirror.gnu.org/automake/automake-1.15.tar.xz'
    sha256 '9908c75aabd49d13661d6dcb1bc382252d22cc77bf733a2d55e87f2aa2db8636'
    version '1.15'

    label :compiler_agnostic
    label :system_first, command: 'automake'

    depends_on :autoconf

    def install
      run './configure', "--prefix=#{prefix}"
      run 'make', 'install'
    end
  end
end
