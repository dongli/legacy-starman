module STARMAN
  class Netcdf_fortran < Package
    homepage 'http://www.unidata.ucar.edu/software/netcdf'
    url 'https://github.com/Unidata/netcdf-fortran/archive/v4.4.4.tar.gz'
    sha256 '44b1986c427989604df9925dcdbf6c1a977e4ecbde6dd459114bca20bf5e9e67'
    version '4.4.4'
    filename 'netcdf-fortran-4.4.4.tar.gz'
    language :fortran

    belongs_to :netcdf

    option 'with-mpi', {
      :desc => 'Build with parallel IO. MPI library is needed.',
      :accept_value => { :boolean => false }
    }

    depends_on :netcdf_c

    def install
      if not CompilerStore.compiler(:fortran)
        CLI.report_error 'Fortran compiler is not available in this compiler set!'
      end
      args = %W[
        --prefix=#{prefix}
        --disable-dependency-tracking
        --disable-dap-remote-tests
        --enable-static
        --enable-shared
      ]
      args << '--enable-parallel-tests' if with_mpi?
      run './configure', *args
      run 'make'
      run 'make', 'check'
      run 'make', 'install'
    end
  end
end
