module STARMAN
  class Dbus < Package
    homepage 'https://wiki.freedesktop.org/www/Software/dbus'
    url 'https://dbus.freedesktop.org/releases/dbus/dbus-1.10.8.tar.gz'
    sha256 'baf3d22baa26d3bdd9edc587736cd5562196ce67996d65b82103bedbe1f0c014'
    version '1.10.8'

    depends_on :expat unless OS.mac?

    patch do
      url 'https://raw.githubusercontent.com/Homebrew/formula-patches/0a8a55872e/d-bus/org.freedesktop.dbus-session.plist.osx.diff'
      sha256 'a8aa6fe3f2d8f873ad3f683013491f5362d551bf5d4c3b469f1efbc5459a20dc'
    end

    def install
      ENV['TMPDIR'] = '/tmp'
      args = %W[
        --disable-dependency-tracking
        --prefix=#{prefix}
        --disable-xml-docs
        --disable-doxygen-docs
        --without-x
        --disable-tests
      ]
      if OS.mac?
        args << '--enable-launchd'
        args << '--with-launchd-agent-dir=#{prefix}'
      end
      run './configure', *args
      run 'make'
      run 'make', 'install'
    end

    def post_install
      # Generate D-Bus's UUID for this machine
      run "#{bin}/dbus-uuidgen", "--ensure=#{var}/lib/dbus/machine-id"
    end
  end
end
