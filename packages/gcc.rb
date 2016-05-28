module STARMAN
  class Gcc < Package
    homepage 'https://gcc.gnu.org'
    url 'http://ftpmirror.gnu.org/gcc/gcc-6.1.0/gcc-6.1.0.tar.bz2'
    sha256 '09c4c85cabebb971b1de732a0219609f93fc0af5f86f6e437fd8d7f832f1a351'
    version '6.1.0'
    language :c, :cxx

    label :compiler

    option 'with-fortran', {
      desc: 'Build gfortran compiler.',
      accept_value: { boolean: true },
      extra: { need_compiler: false }
    }

    depends_on :gmp
    depends_on :mpfr
    depends_on :mpc
    depends_on :isl

    def shipped_compilers
      compilers = {
        c: 'gcc',
        cxx: 'g++'
      }
      compilers[:fortran] = 'gfortran' if with_fortran?
      compilers
    end

    def install
      args = %W[
        --prefix=#{prefix}
        --enable-languages=#{shipped_compilers.keys.join(',').gsub('cxx', 'c++')}
        --with-gmp=#{Gmp.prefix}
        --with-mpfr=#{Mpfr.prefix}
        --with-mpc=#{Mpc.prefix}
        --with-isl=#{Isl.prefix}
        --enable-stage1-checking
        --enable-checking=release
        --enable-lto
        --disable-multilib
        --with-build-config=bootstrap-debug
        --disable-werror
        --with-pkgversion='STARMAN #{Time.now}'
        --with-bugurl=https://github.com/dongli/starman/issues
      ]
      FileUtils.mkdir 'build'
      work_in 'build' do
        run '../configure', *args
        run 'make', 'bootstrap'
        run 'make', 'install', :single_job
      end
    end
  end
end
