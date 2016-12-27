module STARMAN
  class Netcdf_cxx_legacy < Package
    url 'https://www.unidata.ucar.edu/downloads/netcdf/ftp/netcdf-cxx-4.2.tar.gz'
    sha256 '95ed6ab49a0ee001255eac4e44aacb5ca4ea96ba850c08337a3e4c9a0872ccd1'
    version '4.2'
    language :cxx

    belongs_to :netcdf

    def install
      args = %W[
        --prefix=#{prefix}
        --disable-dependency-tracking
      ]
      run './configure', *args
      run 'make'
      run 'make', 'check', :single_job unless skip_test?
      run 'make', 'install'
    end
  end
end
