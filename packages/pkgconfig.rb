module STARMAN
  class Pkgconfig < Package
    homepage 'https://freedesktop.org/wiki/Software/pkg-config/'
    url 'https://pkgconfig.freedesktop.org/releases/pkg-config-0.29.1.tar.gz'
    sha256 'beb43c9e064555469bd4390dcfd8030b1536e0aa103f08d7abf7ae8cac0cb001'
    version '0.29.1'

    label :compiler_agnostic
    label :system_first, command: 'pkg-config'

    depends_on :libiconv

    def install
      args = %W[
        --prefix=#{prefix}
        --disable-debug
        --disable-host-tool
        --with-internal-glib
        --with-libiconv=gnu
      ]
      System::Shell.append 'LDFLAGS', '-framework Foundation -framework Cocoa' if OS.mac?
      run './configure', *args
      run 'make'
      run 'make', 'check' if not skip_test?
      run 'make', 'install'
    end
  end
end
