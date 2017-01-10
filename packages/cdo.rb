module STARMAN
  class Cdo < Package
    url 'https://code.zmaw.de/attachments/download/12760/cdo-1.7.2.tar.gz'
    sha256 '4c43eba7a95f77457bfe0d30fb82382b3b5f2b0cf90aca6f0f0a008f6cc7e697'
    version '1.7.2'

    option :'with-magics', {
      desc: 'Build MAGICS supports.',
      accept_value: { boolean: false }
    }

    depends_on :grib_api
    depends_on :hdf5
    depends_on :jasper
    depends_on :libxml2
    depends_on :magics if with_magics?
    depends_on :netcdf
    depends_on :proj
    depends_on :szip
    depends_on :udunits
    depends_on :zlib

    def install
      if CompilerStore.compiler(:c).vendor == :intel and OS.mac?
        CLI.report_error "#{CLI.blue 'cdo'} can not be built by Intel C compiler on Mac!"
      end
      inreplace 'test/tsformat.test.in', {
        'test -n "$CDO"      || CDO=cdo' => "CDO='#{pwd}/src/cdo -L'"
      }
      args = %W[
        --prefix=#{prefix}
        --with-hdf5=#{Hdf5.prefix}
        --with-netcdf=#{Netcdf.prefix}
        --with-zlib=#{Zlib.prefix}
        --with-szlib=#{Szip.prefix}
        --with-jasper=#{Jasper.prefix}
        --with-grib_api=#{Grib_api.prefix}
        --with-udunits2=#{Udunits.prefix}
        --with-proj=#{Proj.prefix}
        --with-libxml2=#{Libxml2.prefix}
        --disable-dependency-tracking
        --disable-debug
      ]
      run './configure', *args
      run 'make'
      run 'make', 'check' unless skip_test?
      run 'make', 'install'
    end
  end
end
