module STARMAN
  class Gflags < Package
    homepage 'https://gflags.github.io/gflags/'
    url 'https://github.com/gflags/gflags/archive/v2.1.2.tar.gz'
    sha256 'd8331bd0f7367c8afd5fcb5f5e85e96868a00fd24b7276fa5fcee1e5575c2662'
    version '2.1.2'

    depends_on :cmake if needs_build?

    def install
      args = std_cmake_args
      args << '-DBUILD_SHARED_LIBS=ON'
      mkdir 'build' do
        run 'cmake', '..', *args
        run 'make', 'install'
      end
    end
  end
end
