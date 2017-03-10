module STARMAN
  class Gcc < Package
    homepage 'https://gcc.gnu.org'
    url 'http://ftpmirror.gnu.org/gcc/gcc-6.3.0/gcc-6.3.0.tar.bz2'
    sha256 'f06ae7f3f790fbf0f018f6d40e844451e6bc3b7bc96e128e63b09825c1f8b29f'
    version '6.3.0'
    language :c, :cxx

    label :compiler

    option 'with-fortran', {
      desc: 'Build gfortran compiler.',
      accept_value: { boolean: true },
      extra: { need_compiler: false }
    }

    depends_on :libiconv
    # depends_on :dejagnu if needs_build?

    resource :mpfr do
      url 'ftp://gcc.gnu.org/pub/gcc/infrastructure/mpfr-2.4.2.tar.bz2'
      sha256 'c7e75a08a8d49d2082e4caee1591a05d11b9d5627514e678f02d66a124bcf2ba'
    end

    resource :gmp do
      url 'ftp://gcc.gnu.org/pub/gcc/infrastructure/gmp-4.3.2.tar.bz2'
      sha256 '936162c0312886c21581002b79932829aa048cfaf9937c6265aeaa14f1cd1775'
    end

    resource :mpc do
      url 'ftp://gcc.gnu.org/pub/gcc/infrastructure/mpc-0.8.1.tar.gz'
      sha256 'e664603757251fd8a352848276497a4c79b7f8b21fd8aedd5cc0598a38fee3e4'
    end

    resource :isl do
      url 'ftp://gcc.gnu.org/pub/gcc/infrastructure/isl-0.15.tar.bz2'
      sha256 '8ceebbf4d9a81afa2b4449113cee4b7cb14a687d7a549a963deb5e2a41458b6b'
    end

    def shipped_compilers
      return @compilers if @compilers
      @compilers = {
        c: 'gcc',
        cxx: 'g++'
      }
      @compilers[:fortran] = 'gfortran' if with_fortran?
      @compilers
    end

    def version_suffix
      version.to_s.slice(/\d/)
    end

    def install
      ENV.delete 'LD'
      ENV['LIBRARY_PATH'] = ENV['LIBRARY_PATH'].gsub(/:$/, '') if ENV['LIBRARY_PATH']
      args = %W[
        --prefix=#{prefix}
        --libdir=#{lib}/gcc/#{version_suffix}
        --enable-languages=#{shipped_compilers.keys.join(',').gsub('cxx', 'c++')}
        --disable-multilib
        --with-system-zlib
        --enable-libstdcxx-time=yes
        --enable-stage1-checking
        --enable-checking=release
        --enable-lto
        --with-build-config=bootstrap-debug
        --disable-werror
        --disable-nls
        --with-pkgversion='STARMAN #{Time.now}'
        --with-bugurl=https://github.com/dongli/starman/issues
      ]

      inreplace 'libgcc/config/t-slibgcc-darwin', '@shlib_slibdir@', "#{lib}/gcc/#{version_suffix}"
      `grep -lr '@LIBICONV@' *`.split("\n").each do |file|
        inreplace file, '@LIBICONV@', "-L#{Libiconv.lib} @LIBICONV@"
      end

      install_resource :mpfr, '.'
      mv 'mpfr-2.4.2', 'mpfr'
      install_resource :gmp, '.'
      mv 'gmp-4.3.2', 'gmp'
      install_resource :mpc, '.'
      mv 'mpc-0.8.1', 'mpc'
      install_resource :isl, '.'
      mv 'isl-0.15', 'isl'

      mkdir 'build' do
        run '../configure', *args
        run 'make', 'bootstrap'
        # run 'ulimit -s 32768 && make -k check' if not skip_test?
        run 'make', 'install', :single_job
      end
    end
  end
end
