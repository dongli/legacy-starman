module STARMAN
  class Freetype < Package
    homepage 'https://www.freetype.org/'
    url 'https://downloads.sf.net/project/freetype/freetype2/2.6.5/freetype-2.6.5.tar.bz2'
    sha256 'e20a6e1400798fd5e3d831dd821b61c35b1f9a6465d6b18a53a9df4cf441acf0'
    version '2.6.5'

    label :compiler_agnostic

    option 'without-subpixel', {
      desc: 'Disable sub-pixel rendering (a.k.a. LCD rendering, or ClearType).',
      accept_value: { boolean: false }
    }

    depends_on :libpng
    depends_on :zlib
    depends_on :bzip2

    def install
      if not without_subpixel?
        inreplace 'include/freetype/config/ftoption.h',
          '/* #define FT_CONFIG_OPTION_SUBPIXEL_RENDERING */',
          '#define FT_CONFIG_OPTION_SUBPIXEL_RENDERING'
      end
      args = %W[
        --prefix=#{prefix}
        --without-harfbuzz
        LIBPNG_CFLAGS='-I#{Libpng.inc}'
        LIBPNG_LIBS='-L#{Libpng.lib} -lpng'
        ZLIB_CFLAGS='-I#{Zlib.inc}'
        ZLIB_LIBS='-L#{Zlib.lib} -lz'
        BZIP2_CFLAGS='-I#{Bzip2.inc}'
        BZIP2_LIBS='-L#{Bzip2.lib} -lbz2'

      ]
      run './configure', *args
      run 'make'
      run 'make', 'install'
    end
  end
end
