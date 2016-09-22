module STARMAN
  class Webp < Package
    homepage 'https://developers.google.com/speed/webp/'
    url 'http://downloads.webmproject.org/releases/webp/libwebp-0.5.1.tar.gz'
    sha256 '6ad66c6fcd60a023de20b6856b03da8c7d347269d76b1fd9c3287e8b5e8813df'
    version '0.5.1'

    depends_on :libpng
    depends_on :libjpeg
    depends_on :libtiff
    depends_on :giflib

    def install
      args = %W[
        --prefix=#{prefix}
        --disable-dependency-tracking
        --enable-libwebpmux
        --enable-libwebpdemux
        --enable-libwebpdecoder
      ]
      run './configure', *args
      run 'make', 'install'
    end
  end
end
