module STARMAN
  class Libpng < Package
    homepage 'http://www.libpng.org/pub/png/libpng.html'
    url 'https://bintray.com/starman/backup/download_file?file_path=libpng-1.6.26.tar.xz'
    sha256 '266743a326986c3dbcee9d89b640595f6b16a293fd02b37d8c91348d317b73f9'
    version '1.6.26'
    filename 'libpng-1.6.26.tar.xz'

    label :compiler_agnostic
    label :system_conflict

    depends_on :tar if needs_build?
    depends_on :zlib

    def install
      args = %W[
        --disable-dependency-tracking
        --disable-silent-rules
        --prefix=#{prefix}
        --with-zlib-prefix=#{Zlib.prefix}
        LDFLAGS='-L#{Zlib.lib}'
      ]
      run './configure', *args
      run 'make'
      run 'make', 'test' unless skip_test?
      run 'make', 'install'
    end
  end
end
