module STARMAN
  class Mlpack < Package
    homepage 'http://www.mlpack.org'
    url 'http://www.mlpack.org/files/mlpack-2.0.3.tar.gz'
    sha256 '3682c698aac1cd0f2f00d0484fdd033ab33f0ead88666c392312272919e20adb'
    version '2.0.3'
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
      work_in 'build' do
        run 'cmake', '..', *args
        run 'make'
        run 'make', 'test' if not skip_test?
        run 'make', 'install'
      end
    end
  end
end
