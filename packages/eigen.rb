module STARMAN
  class Eigen < Package
    homepage 'https://eigen.tuxfamily.org/'
    url 'https://bitbucket.org/eigen/eigen/get/3.2.9.tar.bz2'
    sha256 '4d1e036ec1ed4f4805d5c6752b76072d67538889f4003fadf2f6e00a825845ff'
    version '3.2.9'
    filename 'eigen-3.2.9.tar.bz2'

    depends_on :cmake if needs_build?

    def install
      mkdir 'build' do
        args = std_cmake_args
        args << "-Dpkg_config_libdir=#{lib}" << '..'
        run 'cmake', *args
        run 'make', 'install'
      end
      cp 'cmake/FindEigen3.cmake', "#{Cmake.share}/cmake-#{VersionSpec.new(Cmake.version).major_minor}/Modules/"
    end
  end
end
