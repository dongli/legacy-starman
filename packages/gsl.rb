module STARMAN
  class Gsl < Package
    homepage 'https://www.gnu.org/software/gsl/'
    url 'https://ftpmirror.gnu.org/gsl/gsl-2.3.tar.gz'
    sha256 '562500b789cd599b3a4f88547a7a3280538ab2ff4939504c8b4ac4ca25feadfb'
    version '2.3'

    def install
      args = %W[
        --prefix=#{prefix}
        --disable-dependency-tracking
      ]
      run './configure', *args
      run 'make'
      run 'make', 'install'
    end
  end
end
