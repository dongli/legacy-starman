module STARMAN
  class Texinfo < Package
    homepage 'https://www.gnu.org/software/texinfo/'
    url 'https://ftpmirror.gnu.org/texinfo/texinfo-6.1.tar.gz'
    sha256 '02582b6d9b0552f1cb1312be6bd7023e9799603c3b2320fa68a36029e4cbafbb'
    version '6.1'

    label :compiler_agnostic
    label :system_first, command: 'texi2pdf' unless OS.mac?

    def install
      args =  %W[
        --prefix=#{prefix}
        --disable-dependency-tracking
        --disable-install-warnings
      ]
      run './configure', *args
      run 'make'
      run 'make', 'install'
    end
  end
end
