module STARMAN
  class Udunits < Package
    homepage 'https://www.unidata.ucar.edu/software/udunits/'
    url 'ftp://ftp.unidata.ucar.edu/pub/udunits/udunits-2.2.20.tar.gz'
    sha256 'f10a02014bc6a200d50d8719997bb3a6b3d364de688469d2f7d599688dd9d195'
    version '2.2.20'

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
