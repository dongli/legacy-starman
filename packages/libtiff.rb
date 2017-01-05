module STARMAN
  class Libtiff < Package
    homepage 'http://www.remotesensing.org/libtiff/'
    url 'http://download.osgeo.org/libtiff/tiff-4.0.7.tar.gz'
    sha256 '9f43a2cfb9589e5cecaa66e16bf87f814c945f22df7ba600d63aac4632c4f019'
    version '4.0.7'

    label :system_conflict if OS.mac?

    depends_on :libjpeg
    depends_on :xz

    def install
      args = %W[
        --disable-dependency-tracking
        --prefix=#{prefix}
        --without-x
        --with-jpeg-include-dir=#{Libjpeg.inc}
        --with-jpeg-lib-dir=#{Libjpeg.lib}
        --with-lzma-include-dir=#{Xz.inc}
        --with-lzma-lib-dir=#{Xz.lib}
      ]
      run './configure', *args
      run 'make', 'install'
    end
  end
end
