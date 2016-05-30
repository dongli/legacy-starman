module STARMAN
  class Esmf < Package
    homepage 'https://earthsystemcog.org/projects/esmf/'
    url 'http://www.earthsystemmodeling.org/esmf_releases/non_public/ESMF_7_0_0/esmf_7_0_0_src.tar.gz'
    sha256 'b2ac25f78c4bded006360230bd229953909f2a9f9e71b732833c240edc7707b1'
    version '7.0.0'
    language :c, :cxx, :fortran

    option 'use-pio', {
      :desc => 'Choose to use PIO library.',
      :accept_value => { :boolean => true }
    }

    depends_on :lapack
    depends_on :netcdf
    depends_on :pio if use_pio?

    def export_env
      {
        'ESMFMKFILE' => "#{Dir.glob("#{lib}/libO/**/esmf.mk").first}"
      }
    end

    def install
      System::Shell.set 'ESMF_DIR', FileUtils.pwd
      # System::Shell.set 'ESMF_CPP', ENV['CC']
      System::Shell.set 'ESMF_CXXCOMPILER', ENV['CXX']
      System::Shell.set 'ESMF_CXXLINKER', ENV['CXX']
      System::Shell.set 'ESMF_F90COMPILER', ENV['FC']
      System::Shell.set 'ESMF_F90LINKER', ENV['FC']
      System::Shell.set 'ESMF_LAPACK', 'system'
      System::Shell.set 'ESMF_LAPACK_LIBPATH', Lapack.lib
      System::Shell.set 'ESMF_LAPACK_LIBS', "-Wl,-rpath,#{Lapack.lib} -llapack -lblas"
      System::Shell.set 'ESMF_INSTALL_PREFIX', prefix
      replace 'src/Infrastructure/Mesh/src/Moab/io/ReadABAQUS.cpp',
        'if (NULL != abFile)', 'if (abFile.is_open())'
      run 'make'
      run 'make', 'check' if not skip_test?
      run 'make', 'install'
    end
  end
end
