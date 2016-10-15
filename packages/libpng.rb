module STARMAN
  class Libpng < Package
    homepage 'http://www.libpng.org/pub/png/libpng.html'
    url 'http://jaist.dl.sourceforge.net/project/libpng/libpng16/1.6.24/libpng-1.6.24.tar.xz'
    sha256 '7932dc9e5e45d55ece9d204e90196bbb5f2c82741ccb0f7e10d07d364a6fd6dd'
    version '1.6.24'

    label :compiler_agnostic
    label :system_conflict

    def install
      args = %W[
        --disable-dependency-tracking
        --disable-silent-rules
        --prefix=#{prefix}
      ]
      run './configure', *args
      run 'make'
      run 'make', 'test'
      run 'make', 'install'
    end
  end
end
