module STARMAN
  class Openmotif < Package
    url 'https://downloads.sourceforge.net/project/motif/Motif%202.3.6%20Source%20Code/motif-2.3.6.tar.gz'
    sha256 'fa810e6bedeca0f5a2eb8216f42129bcf6bd23919068d433e386b7bfc05d58cf'
    version '2.3.6'

    depends_on :fontconfig
    depends_on :freetype
    depends_on :libjpeg
    depends_on :libpng
    depends_on :pkgconfig if needs_build?

    def install
      args = %W[
        --prefix=#{prefix}
        --disable-dependency-tracking
        --disable-silent-rules
      ]
      run './configure', *args
      run 'make'
      run 'make', 'install'
    end
  end
end
