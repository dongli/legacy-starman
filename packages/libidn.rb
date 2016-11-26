module STARMAN
  class Libidn < Package
    url 'https://ftpmirror.gnu.org/libidn/libidn-1.33.tar.gz'
    sha256 '44a7aab635bb721ceef6beecc4d49dfd19478325e1b47f3196f7d2acc4930e19'
    version '1.33'

    depends_on :pkgconfig if needs_build?

    def install
      args = %W[
        --prefix=#{prefix}
        --disable-dependency-tracking
        --disable-csharp
      ]
      run './configure', *args
      run 'make', 'install'
    end
  end
end
