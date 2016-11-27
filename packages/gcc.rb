module STARMAN
  class Gcc < Package
    homepage 'https://gcc.gnu.org'
    url 'http://ftpmirror.gnu.org/gcc/gcc-6.2.0/gcc-6.2.0.tar.bz2'
    sha256 '9944589fc722d3e66308c0ce5257788ebd7872982a718aa2516123940671b7c5'
    version '6.2.0'
    language :c, :cxx

    label :compiler

    option 'with-fortran', {
      desc: 'Build gfortran compiler.',
      accept_value: { boolean: true },
      extra: { need_compiler: false }
    }

    depends_on :wget if needs_build?
    depends_on :libiconv
    # depends_on :dejagnu if needs_build?

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

      run './contrib/download_prerequisites'

      mkdir 'build' do
        run '../configure', *args
        run 'make', 'bootstrap'
        # run 'ulimit -s 32768 && make -k check' if not skip_test?
        run 'make', 'install', :single_job
      end
    end
  end
end
