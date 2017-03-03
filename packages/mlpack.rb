module STARMAN
  class Mlpack < Package
    homepage 'http://www.mlpack.org'
    url 'http://www.mlpack.org/files/mlpack-2.1.1.tar.gz'
    sha256 'c2249bbab5686bb8658300ebcf814b81ac7b8050a10f1a517ba5530c58dbac31'
    version '2.1.1'
    language :cxx

    depends_on :cmake if needs_build?
    depends_on :libxml2
    depends_on :armadillo
    depends_on :boost

    def install
      args = std_cmake_args
      args << "-DBOOST_ROOT=#{Boost.prefix}"
      args << "-DARMADILLO_INCLUDE_DIR=#{Armadillo.inc}"
      args << "-DARMADILLO_LIBRARY=#{Armadillo.lib}/libarmadillo.#{OS.soname}"
      mkdir 'build' do
        run 'cmake', '..', *args
        run 'make'
        run 'make', 'test' if not skip_test?
        run 'make', 'install'
      end
    end
  end
end
