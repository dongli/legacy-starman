module STARMAN
  class Esmf < Package
    homepage 'https://earthsystemcog.org/projects/esmf/'
    url 'http://www.earthsystemmodeling.org/esmf_releases/non_public/ESMF_7_0_0/esmf_7_0_0_src.tar.gz'
    sha256 'b2ac25f78c4bded006360230bd229953909f2a9f9e71b732833c240edc7707b1'
    version '7.0.0'
    language :c, :cxx, :fortran

    option 'mpi', {
      desc: 'Set which MPI library to use.',
      accept_value: { string: 'mpiuni' },
      possible_values: %W[ mpich mpich2 lam openmpi intelmpi mpiuni ]
    }
    option 'with-pio', {
      desc: 'Choose to use PIO library.',
      accept_value: { boolean: false }
    }
    option 'with-openmp', {
      desc: 'Use OpenMP v4.0 interface provided by compilers.',
      accept_value: { boolean: false }
    }

    depends_on :lapack
    if with_pio?
      depends_on :netcdf, 'with-mpi' => true
      depends_on :pio
    else
      depends_on :netcdf
    end

    def export_env
      System::Shell.set 'ESMFMKFILE', "#{lib}/esmf.mk"
    end

    def install
      CLI.report_error "Option #{CLI.red 'mpi'} cannot be 'mpiuni' when #{CLI.red 'with-openmp'}!" if mpi == 'mpiuni' and with_openmp?
      System::Shell.set 'ESMF_DIR', pwd
      # System::Shell.set 'ESMF_CPP', ENV['CC']
      System::Shell.set 'ESMF_CXXCOMPILER', ENV['CXX']
      System::Shell.set 'ESMF_CXXLINKER', ENV['CXX']
      System::Shell.set 'ESMF_F90COMPILER', ENV['FC']
      System::Shell.set 'ESMF_F90LINKER', ENV['FC']
      System::Shell.set 'ESMF_LAPACK', 'system'
      System::Shell.set 'ESMF_LAPACK_LIBPATH', Lapack.lib
      System::Shell.set 'ESMF_LAPACK_LIBS', "-Wl,-rpath,#{Lapack.lib} -llapack -lblas"
      System::Shell.set 'ESMF_NETCDF', 'split'
      System::Shell.set 'ESMF_NETCDF_INCLUDE', Netcdf.inc
      System::Shell.set 'ESMF_NETCDF_LIBPATH', Netcdf.lib
      System::Shell.set 'ESMF_NETCDF_LIBS', "-Wl,-rpath,#{Netcdf.lib} -lnetcdf -lnetcdff"
      if with_pio?
        System::Shell.set 'ESMF_PNETCDF', 'standard'
        System::Shell.set 'ESMF_PNETCDF_INCLUDE', Pnetcdf.inc
        System::Shell.set 'ESMF_PNETCDF_LIBPATH', Pnetcdf.lib
        System::Shell.set 'ESMF_PNETCDF_LIBS', "-Wl,-rpath,#{Pnetcdf.lib} -lpnetcdf"
        System::Shell.set 'ESMF_PIO', 'internal'
      end
      System::Shell.set 'ESMF_ACC_SOFTWARE_STACK', 'openmp4' if with_openmp?
      System::Shell.set 'ESMF_COMM', mpi
      System::Shell.set 'ESMF_INSTALL_PREFIX', prefix
      System::Shell.set 'ESMF_INSTALL_BINDIR', bin
      System::Shell.set 'ESMF_INSTALL_HEADERDIR', inc
      System::Shell.set 'ESMF_INSTALL_LIBDIR', lib
      System::Shell.set 'ESMF_INSTALL_MODDIR', "#{prefix}/mod"

      inreplace 'src/Infrastructure/Mesh/src/Moab/io/ReadABAQUS.cpp',
        'if (NULL != abFile)', 'if (abFile.is_open())'
      run 'make'
      run 'make', 'check' if not skip_test?
      run 'make', 'install'
    end
  end
end
