module STARMAN
  class Cdo < Package
    url 'https://code.zmaw.de/attachments/download/14686/cdo-1.8.2.tar.gz'
    sha256 '6ca6c1263af2237737728ac937a275f8aa27680507636a6b6320f347c69a369a'
    version '1.8.2'

    option :'with-magics', {
      desc: 'Build MAGICS supports.',
      accept_value: { boolean: false }
    }

    depends_on :grib_api, 'with-python': false
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
      # To avoid potential conflict with cdo test scripts.
      ENV.delete 'suffix'
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
