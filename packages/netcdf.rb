module STARMAN
  class Netcdf < Package
    version '4.4.0'

    label :group_master

    option 'with-cxx', {
      desc: 'Build C++ API bindings.',
      accept_value: { boolean: true },
      cascade: true
    }
    option 'with-fortran', {
      desc: 'Build Fortran API bindings.',
      accept_value: { boolean: true },
      cascade: true
    }
    option 'with-mpi', {
      desc: 'Build C and Fortran API bindings with MPI library.',
      accept_value: { boolean: false },
      cascade: true
    }
    option 'with-dap', {
      desc: 'Build with DAP remote access client support.',
      accept_value: { boolean: false }
    }

    depends_on :netcdf_cxx if with_cxx?
    depends_on :netcdf_fortran if with_fortran?
    depends_on :netcdf_c
  end
end
