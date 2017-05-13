module STARMAN
  class Pnetcdf < Package
    homepage 'https://trac.mcs.anl.gov/projects/parallel-netcdf'
    url 'http://cucis.ece.northwestern.edu/projects/PnetCDF/Release/parallel-netcdf-1.8.1.tar.gz'
    sha256 '8d7d4c9c7b39bb1cbbcf087e0d726551c50f0cc30d44aed3df63daf3772c9043'
    version '1.8.1'

    def install
      args = ["--prefix=#{prefix}"]
      args << '--disable-cxx' if ENV['MPICXX'].empty?
      args << '--disable-fortran' if ENV['MPIFC'].empty?
      run './configure', *args
      run 'make'
      run 'make', 'check' unless skip_test?
      run 'make', 'install'
    end
  end
end
