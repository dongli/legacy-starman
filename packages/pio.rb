module STARMAN
  class Pio < Package
    homepage 'http://ncar.github.io/ParallelIO/'
    url 'https://github.com/NCAR/ParallelIO/archive/pio1.10.0.tar.gz'
    sha256 'b60d100b351cee609f98c24096a57165167f4a28b650700cbe98637f0f8d8873'
    version '1.10.0'
    language :c, :fortran

    depends_on :netcdf, 'use-mpi' => true, 'with-fortran' => true
  end
end
