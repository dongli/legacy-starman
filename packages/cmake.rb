module STARMAN
  class Cmake < Package
    homepage 'https://www.cmake.org/'
    url 'https://cmake.org/files/v3.5/cmake-3.5.2.tar.gz'
    sha256 '92d8410d3d981bb881dfff2aed466da55a58d34c7390d50449aa59b32bb5e62a'
    version '3.5.2'

    label :compiler_agnostic
    label :system_first, command: 'cmake'

    # TODO: Should we specify these two dependencies?
    depends_on :zlib
    depends_on :bzip2

    def install
      args = %W[
        --prefix=#{prefix}
        --parallel=#{CommandLine.options[:'make-jobs'].value}
        --no-system-libs
        --system-zlib
        --system-bzip2
        --system-curl
      ]
      run './bootstrap', *args
      run 'make'
      run 'make', 'install'
    end
  end
end
