module STARMAN
  class Netcdf_c < Package
    homepage 'http://www.unidata.ucar.edu/software/netcdf'
    url 'https://github.com/Unidata/netcdf-c/archive/v4.4.1.1.tar.gz'
    sha256 '7f040a0542ed3f6d27f3002b074e509614e18d6c515b2005d1537fec01b24909'
    version '4.4.1.1'
    filename 'netcdf-c-4.4.1.1.tar.gz'
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

    depends_on :curl if with_dap?
    depends_on :hdf5
    depends_on :m4
    depends_on :pnetcdf if with_mpi?
    depends_on :zlib

    def install
      args = %W[
        --prefix=#{prefix}
        --enable-netcdf-4
        --enable-utilities
        --enable-shared
        --enable-static
        --disable-dap-remote-tests
        --disable-doxygen
        LDFLAGS='-L#{Hdf5.lib} -L#{Zlib.lib}'
      ]
      args << '--enable-pnetcdf' if with_mpi?
      if with_dap?
        args << '--enable-dap'
      else
        args << '--disable-dap'
      end
      run './configure', *args
      run 'make'
      run 'make', 'check', :single_job unless skip_test?
      run 'make', 'install'
    end
  end
end
