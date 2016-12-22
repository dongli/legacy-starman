module STARMAN
  class Libxslt < Package
    url 'http://xmlsoft.org/sources/libxslt-1.1.29.tar.gz'
    sha256 'b5976e3857837e7617b29f2249ebb5eeac34e249208d31f1fbf7a6ba7a4090ce'
    version '1.29'

    depends_on :libxml2

    def install
      args = %W[
        --prefix=#{prefix}
        --disable-dependency-tracking
        --disable-silent-rules
        --with-libxml-prefix=#{Libxml2.prefix}
      ]

      # https://bugzilla.gnome.org/show_bug.cgi?id=762967
      inreplace 'configure', /PYTHON_LIBS=.*/, 'PYTHON_LIBS="-undefined dynamic_lookup"'

      system './configure', *args
      system 'make'
      system 'make', 'install'
    end
  end
end
