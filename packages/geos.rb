module STARMAN
  class Geos < Package
    url 'http://download.osgeo.org/geos/geos-3.6.1.tar.bz2'
    sha256 '4a2e4e3a7a09a7cfda3211d0f4a235d9fd3176ddf64bd8db14b4ead266189fc5'
    version '3.6.1'

    option 'with-python', {
      desc: 'Build Python extension.',
      accept_value: { boolean: false }
    }
    option 'with-ruby', {
      desc: 'Build Ruby extension.',
      accept_value: { boolean: false }
    }

    depends_on :python3 if with_python?
    depends_on :ruby if with_ruby?
    depends_on :swig if needs_build? and (with_python? or with_ruby?)

    def install
      if with_python?
        inreplace 'configure', {
          /PYTHON_CPPFLAGS=.*/ => "PYTHON_CPPFLAGS='#{`python3-config --includes`.strip}'",
          /PYTHON_LDFLAGS=.*/ => 'PYTHON_LDFLAGS="-Wl,-undefined,dynamic_lookup"',
        }
      end
      args = %W[
        --disable-dependency-tracking
        --prefix=#{prefix}
      ]
      args << '--enable-python' if with_python?
      args << '--enable-ruby' if with_ruby?
      run './configure', *args
      run 'make', 'install'
    end
  end
end
