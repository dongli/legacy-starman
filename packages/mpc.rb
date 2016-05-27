module STARMAN
  class Mpc < Package
    homepage 'http://multiprecision.org'
    url 'http://ftpmirror.gnu.org/mpc/mpc-1.0.3.tar.gz'
    mirror 'http://multiprecision.org/mpc/download/mpc-1.0.3.tar.gz'
    sha256 '617decc6ea09889fb08ede330917a00b16809b8db88c29c31bfbb49cbf88ecc3'
    version '1.0.3'

    depends_on :gmp
    depends_on :mpfr

    def install
      args = %W[
        --prefix=#{prefix}
        --disable-dependency-tracking
        --with-gmp=#{Gmp.prefix}
        --with-mpfr=#{Mpfr.prefix}
      ]
      run './configure', *args
      run 'make'
      run 'make', 'check' if not skip_test?
      run 'make', 'install'
    end
  end
end
