module STARMAN
  class Mlpack < Package
    homepage 'http://www.mlpack.org'
    url 'http://www.mlpack.org/files/mlpack-2.0.2.tar.gz'
    sha256 '1b50eb81c418f2c420bf9957092396760bd21775a8c65f317ed93370b26d2038'
    version '2.0.2'
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
