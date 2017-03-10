module STARMAN
  class Cmake < Package
    homepage 'https://www.cmake.org/'
    url 'https://cmake.org/files/v3.7/cmake-3.7.2.tar.gz'
    sha256 'dc1246c4e6d168ea4d6e042cfba577c1acd65feea27e56f5ff37df920c30cae0'
    version '3.7.2'

    label :compiler_agnostic
    label :system_first, command: 'cmake'

    # TODO: Should we specify these two dependencies?
    depends_on :zlib
    depends_on :bzip2

    def install
      if CompilerStore.compiler(:c).vendor == :gnu and OS.mac?
        CLI.report_error "#{CLI.blue 'cmake'} can not be built by GCC compiler on Mac!"
      end
      args = %W[
        --prefix=#{prefix}
        --parallel=#{CommandLine.options[:'make-jobs'].value}
        --no-system-libs
        --system-zlib
        --system-bzip2
        --system-curl
      ]
      inreplace 'CMakeLists.txt', 'find_package(ZLIB)', "set(ZLIB_ROOT '#{Zlib.prefix}')\nfind_package(ZLIB)"
      run './bootstrap', *args
      run 'make'
      run 'make', 'install'
    end
  end
end
