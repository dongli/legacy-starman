module STARMAN
  class Gmp < Package
    homepage 'https://gmplib.org/'
    url 'https://gmplib.org/download/gmp/gmp-6.1.0.tar.xz'
    mirror 'https://ftp.gnu.org/gnu/gmp/gmp-6.1.0.tar.xz'
    sha256 '68dadacce515b0f8a54f510edf07c1b636492bcdb8e8d54c56eb216225d16989'
    version '6.1.0'
    language :c, :cxx

    depends_on :m4 if needs_build?

    def install
      args = %W[
        --prefix=#{prefix}
        --enable-cxx
      ]
      System::Shell.append 'CXX', CompilerStore.compiler(:cxx).flags[:cxx11]
      run './configure', *args
      run 'make'
      run 'make', 'check' if not skip_test?
      run 'make', 'install'
    end
  end
end
