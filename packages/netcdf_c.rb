module STARMAN
  class Netcdf_c < Package
    homepage 'http://www.unidata.ucar.edu/software/netcdf'
    url 'https://github.com/Unidata/netcdf-c/archive/v4.4.0.tar.gz'
    sha256 '09b78b152d3fd373bee4b5738dc05c7b2f5315fe34aa2d94ee9256661119112f'
    version '4.4.0'
    filename 'netcdf-c-4.4.0.tar.gz'
    language :c

    belongs_to :netcdf

    option 'with-mpi', {
      :desc => 'Build with parallel IO. MPI library is needed.',
      :accept_value => { :boolean => false }
    }
    option 'with-dap', {
      :desc => 'Build with DAP remote access client support.',
      :accept_value => { :boolean => false }
    }

    depends_on :m4
    depends_on :hdf5
    depends_on :curl if with_dap?
    depends_on :pnetcdf if with_mpi?

    def install
      args = %W[
        --prefix=#{prefix}
        --enable-netcdf-4
        --enable-utilities
        --enable-shared
        --enable-static
        --disable-dap-remote-tests
        --disable-doxygen
        LDFLAGS='-L#{Hdf5.lib}'
      ]
      args << '--enable-pnetcdf' if with_mpi?
      if with_dap?
        args << '--enable-dap'
      else
        args << '--disable-dap'
      end
      run './configure', *args
      run 'make'
      run 'make', 'check' if not skip_test?
      run 'make', 'install'
    end
  end
end
