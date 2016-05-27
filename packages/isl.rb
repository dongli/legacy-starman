module STARMAN
  class Isl < Package
    homepage 'http://isl.gforge.inria.fr'
    url 'http://isl.gforge.inria.fr/isl-0.17.1.tar.bz2'
    sha256 'd6307bf9a59514087abac3cbaab3d99393a0abb519354f7e7834a8c842310daa'
    version '0.17.1'
    language :c

    depends_on :gmp

    def install
      args = %W[
        --prefix=#{prefix}
        --disable-dependency-tracking
        --disable-silent-rules
        --with-gmp=system
        --with-gmp-prefix=#{Gmp.prefix}
      ]
      run './configure', *args
      run 'make', 'install'
    end
  end
end
