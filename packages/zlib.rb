module STARMAN
  class Zlib < Package
    homepage 'http://www.zlib.net/'
    url 'http://zlib.net/zlib-1.2.8.tar.gz'
    mirror 'https://downloads.sourceforge.net/project/libpng/zlib/1.2.8/zlib-1.2.8.tar.gz'
    sha256 '36658cb768a54c1d4dec43c3116c27ed893e88b02ecfcb44f2166f9c0b7f2a0d'
    version '1.2.8'
    language :c

    compatible_with '10.11' if OS.mac? and OS.version =~ '10.12'

    def install
      run './configure', "--prefix=#{prefix}"
      run 'make', 'install'
    end
  end
end
