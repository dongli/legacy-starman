module STARMAN
  class Lapack < Package
    homepage 'http://www.netlib.org/lapack/'
    url 'http://www.netlib.org/lapack/lapack-3.6.1.tgz'
    sha256 '888a50d787a9d828074db581c80b2d22bdb91435a673b1bf6cd6eb51aa50d1de'
    version '3.6.1'
    language :fortran

    label :system_conflict if OS.mac?

    depends_on :cmake if needs_build?

    def install
      run 'cmake', '.', '-DBUILD_SHARED_LIBS:BOOL=ON', '-DLAPACKE:BOOL=ON', *std_cmake_args
      run 'make', 'install'
    end
  end
end
