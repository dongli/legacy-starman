module STARMAN
  class Freexl < Package
    url 'https://www.gaia-gis.it/gaia-sins/freexl-sources/freexl-1.0.2.tar.gz'
    sha256 'b39a4814a0f53f5e09a9192c41e3e51bd658843f770399023a963eb064f6409d'
    version '1.0.2'

    def install
      args = %W[
        --disable-dependency-tracking
        --prefix=#{prefix}
        --disable-silent-rules
      ]
      run './configure', *args
      run 'make'
      run 'make', 'check' unless skip_test?
      run 'make', 'install'
    end
  end
end
