module STARMAN
  class Mpfr < Package
    homepage 'http://www.mpfr.org/'
    url 'http://www.mpfr.org/mpfr-current/mpfr-3.1.4.tar.bz2'
    sha256 'd3103a80cdad2407ed581f3618c4bed04e0c92d1cf771a65ead662cc397f7775'
    version '3.1.4'
    language :c

    depends_on :gmp

    def install
      args = %W[
        --prefix=#{prefix}
        --disable-dependency-tracking
        --disable-silent-rules
      ]
      run './configure', *args
      run 'make'
      run 'make', 'check' if not skip_test?
      run 'make', 'install'
    end
  end
end
