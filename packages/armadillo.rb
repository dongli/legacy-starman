module STARMAN
  class Armadillo < Package
    homepage 'http://arma.sourceforge.net/'
    url 'http://heanet.dl.sourceforge.net/project/arma/armadillo-7.600.2.tar.xz'
    sha256 '6790d5e6b41fcac6733632a9c3775239806d00178886226dec3f986a884f4c2d'
    version '7.600.2'
    language :cxx

    option 'with-hdf5', {
      desc: 'Enable the ability to save and load matrices stored in the HDF5 format.',
      accept_value: { boolean: false }
    }

    depends_on :cmake if needs_build?
    depends_on :arpack
    depends_on :superlu
    depends_on :hdf5 if with_hdf5?

    def install
      inreplace 'cmake_aux/Modules/ARMA_FindARPACK.cmake',
        'PATHS ${CMAKE_SYSTEM_LIBRARY_PATH}',
        "PATHS ${CMAKE_SYSTEM_LIBRARY_PATH} #{Arpack.lib}"
      inreplace 'cmake_aux/Modules/ARMA_FindSuperLU5.cmake', {
        'find_path(SuperLU_INCLUDE_DIR slu_ddefs.h' => "find_path(SuperLU_INCLUDE_DIR slu_ddefs.h\n#{Superlu.inc}/superlu",
        'PATHS ${CMAKE_SYSTEM_LIBRARY_PATH}' => "PATHS ${CMAKE_SYSTEM_LIBRARY_PATH} #{Superlu.lib}"
      }

      args = std_cmake_args
      args << '-DDETECT_HDF5=ON' if with_hdf5?
      run 'cmake', '.', *args
      run 'make', 'install'
    end

    def post_install
      # FIXME: Armadillo has a nasty bug in randn when using c++11, so I just
      #        make it not use c++11!
      inreplace "#{prefix}/include/armadillo_bits/config.hpp",
        '#define ARMA_USE_EXTERN_CXX11_RNG',
        '#undef ARMA_USE_EXTERN_CXX11_RNG'
    end
  end
end
