module STARMAN
  class Udunits < Package
    homepage 'https://www.unidata.ucar.edu/software/udunits/'
    url 'ftp://ftp.unidata.ucar.edu/pub/udunits/udunits-2.2.25.tar.gz'
    sha256 'ad486f8f45cba915ac74a38dd15f96a661a1803287373639c17e5a9b59bfd540'
    version '2.2.25'

    depends_on :expat

    def install
      args = %W[
        --prefix=#{prefix}
        --disable-debug
        --disable-dependency-tracking
        CPPFLAGS='-I#{Expat.inc}'
        LDFLAGS='-L#{Expat.lib}'
        LIBS='-lexpat'
      ]
      run './configure', *args
      run 'make', 'install'
    end
  end
end
