module STARMAN
  class Giflib < Package
    homepage 'http://giflib.sourceforge.net/'
    url 'https://downloads.sourceforge.net/project/giflib/giflib-4.x/giflib-4.2.3.tar.bz2'
    sha256 '0ac8d56726f77c8bc9648c93bbb4d6185d32b15ba7bdb702415990f96f3cb766'
    version '4.2.3'

    label :system_conflict if OS.mac?

    def install
      args = %W[
        --prefix=#{prefix}
        --disable-debug
        --disable-dependency-tracking
      ]
      run './configure', *args
      run 'make', 'install'
    end
  end
end
