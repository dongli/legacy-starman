module STARMAN
  class Netcdf < Package
    homepage 'http://www.unidata.ucar.edu/software/netcdf'
    url 'ftp://ftp.unidata.ucar.edu/pub/netcdf/netcdf-4.3.3.1.tar.gz'
    mirror 'http://www.gfd-dennou.org/library/netcdf/unidata-mirror/netcdf-4.3.3.1.tar.gz'
    sha256 'bdde3d8b0e48eed2948ead65f82c5cfb7590313bc32c4cf6c6546e4cea47ba19'
    version '4.3.3.1'

    option :use_mpi, {
      :desc => 'Build with parallel IO. MPI library is needed.',
      :accept_value => { :boolean => false }
    }

    depends_on :pnetcdf if use_mpi?
  end
end
