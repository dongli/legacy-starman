module STARMAN
  class Lapack < Package
    homepage 'http://www.netlib.org/lapack/'
    url 'http://www.netlib.org/lapack/lapack-3.6.0.tgz'
    sha256 'a9a0082c918fe14e377bbd570057616768dca76cbdc713457d8199aaa233ffc3'
    version '3.6.0'
    language :fortran

    label :system_conflict if OS.mac?

    depends_on :cmake if needs_build?

    def install
      run 'cmake', '.', '-DBUILD_SHARED_LIBS:BOOL=ON', '-DLAPACKE:BOOL=ON', *std_cmake_args
      run 'make', 'install'
    end
  end
end
