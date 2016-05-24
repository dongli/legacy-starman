module STARMAN
  class Netcdf < Package
    version '4.4.0'

    label :group_master

    option 'with-cxx', {
      :desc => 'Build C++ API bindings.',
      :accept_value => { :boolean => true }
    }
    option 'with-fortran', {
      :desc => 'Build Fortran API bindings.',
      :accept_value => { :boolean => true }
    }

    depends_on :netcdf_cxx if with_cxx?
    depends_on :netcdf_fortran if with_fortran?
    depends_on :netcdf_c
  end
end
