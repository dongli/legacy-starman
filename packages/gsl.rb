module STARMAN
  class Gsl < Package
    homepage 'https://www.gnu.org/software/gsl/'
    url 'https://ftpmirror.gnu.org/gsl/gsl-2.2.1.tar.gz'
    sha256 '13d23dc7b0824e1405f3f7e7d0776deee9b8f62c62860bf66e7852d402b8b024'
    version '2.2.1'

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
