module STARMAN
  class Armadillo < Package
    homepage 'http://arma.sourceforge.net/'
    url 'http://sourceforge.net/projects/arma/files/armadillo-7.800.1.tar.xz'
    sha256 '5ada65a5a610301ae188bb34f0ac6e7fdafbdbcd0450b0adb7715349ae14b8db'
    version '7.800.1'
    language :cxx

    option 'with-hdf5', {
      desc: 'Enable the ability to save and load matrices stored in the HDF5 format.',
      accept_value: { boolean: false }
    }

    depends_on :cmake if needs_build?
    depends_on :arpack if CompilerStore.compiler(:fortran)
    depends_on :superlu
    depends_on :hdf5 if with_hdf5?

    def install
      if CompilerStore.compiler(:fortran)
        inreplace 'cmake_aux/Modules/ARMA_FindARPACK.cmake',
          'PATHS ${CMAKE_SYSTEM_LIBRARY_PATH}',
          "PATHS ${CMAKE_SYSTEM_LIBRARY_PATH} #{Arpack.lib}"
      end
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
