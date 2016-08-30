module STARMAN
  class Fontconfig < Package
    homepage 'https://wiki.freedesktop.org/www/Software/fontconfig/'
    url 'https://www.freedesktop.org/software/fontconfig/release/fontconfig-2.12.1.tar.bz2'
    sha256 'b449a3e10c47e1d1c7a6ec6e2016cca73d3bd68fbbd4f0ae5cc6b573f7d6c7f3'
    version '2.12.1'

    label :compiler_agnostic

    depends_on :pkgconfig
    depends_on :freetype
    depends_on :libxml2
    depends_on :expat

    def install
      args = %W[
        --disable-dependency-tracking
        --disable-silent-rules
        --enable-static
        --prefix=#{prefix}
        FREETYPE_CFLAGS='-I#{Freetype.inc}/freetype2'
        FREETYPE_LIBS='-L#{Freetype.lib} -lfreetype'
        LIBXML2_CFLAGS='-I#{Libxml2.inc}'
        LIBXML2_LIBS='-L#{Libxml2.lib} -lxml2'
        EXPAT_CFLAGS='-I#{Expat.inc}'
        EXPAT_LIBS='-L#{Expat.lib} -lexpat'
      ]
      args << "--with-add-fonts=/System/Library/Fonts,/Library/Fonts,~/Library/Fonts" if OS.mac?
      run './configure', *args
      run 'make', 'install', 'RUN_FC_CACHE_TEST=false'
    end

    def post_install
      CLI.report_notice 'Regenerating font cache, this may take a while.'
      run "#{bin}/fc-cache", '-frv'
    end
  end
end
