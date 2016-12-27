module STARMAN
  class Magics < Package
    url 'https://software.ecmwf.int/wiki/download/attachments/3473464/Magics-2.30.0-Source.tar.gz?api=v2'
    sha256 ''
    version '2.30.0'
    language :cxx

    depends_on :boost
    depends_on :cmake if needs_build?
    depends_on :grib_api
    depends_on :netcdf
    depends_on :proj
  end
end
