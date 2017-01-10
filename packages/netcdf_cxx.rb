module STARMAN
  class Netcdf_cxx < Package
    homepage 'http://www.unidata.ucar.edu/software/netcdf'
    url 'https://github.com/Unidata/netcdf-cxx4/archive/v4.3.0.tar.gz'
    sha256 '25da1c97d7a01bc4cee34121c32909872edd38404589c0427fefa1301743f18f'
    version '4.3.0'
    filename 'netcdf-cxx4-4.3.0.tar.gz'
    language :cxx

    belongs_to :netcdf

    option 'with-mpi', {
      :desc => 'Build with parallel IO. MPI library is needed.',
      :accept_value => { :boolean => false }
    }

    def install
      args = %W[
        --prefix=#{prefix}
        --disable-dependency-tracking
        --disable-dap-remote-tests
        --enable-static
        --enable-shared
      ]
      run './configure', *args
      run 'make'
      run 'make', 'check', :single_job unless skip_test?
      run 'make', 'install'
    end
  end
end
