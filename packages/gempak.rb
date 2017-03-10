module STARMAN
  class Gempak < Package
    url 'https://github.com/Unidata/gempak/archive/7.3.1.1.tar.gz'
    sha256 'd0d38116898c5963a74f8c236f3f69e1451a108be6fc3fb84acbb6020754baa5'
    version '7.3.1.1'
    filename 'gempak-7.3.1.1.tar.gz'

    depends_on :bzip2
    depends_on :netcdf
    depends_on :jasper
    depends_on :libpng
    depends_on :libxml2
    depends_on :libxslt
    depends_on :bufrlib

    def install
      inreplace 'Gemenviron.profile', {
        /NAWIPS=.*$/ => "NAWIPS=#{pwd}",
        /OS_ROOT=.*$/ => "OS_ROOT=#{prefix}"
      }
      inreplace 'config/Makeinc.common', {
        /OS_ROOT\s*=.*$/ => "OS_ROOT=#{prefix}"
      }
      ['bzip2', 'HDF5', 'JasPer', 'ncepBUFR', 'netCDF', 'PNG', 'xml2', 'xslt', 'zlib'].each do |lib|
        inreplace 'extlibs/Makefile', /#{lib} \\/ => '\\'
      	rm_r "extlibs/#{lib}"
      end
      ['config/Makeinc.common',
       'config/Makeinc.common_linux',
       'config/Makeinc.common_sol',
       'config/Makeinc.common_sav',
       'gempak/source/textlib/xml/Makefile',
       'gempak/source/textlib/xml/testxml_link',
       'gempak/source/contrib/awc/airmet_bufrvgf/Makefile',
       'gempak/source/contrib/awc/airmet_bufrvgf/airmet_bufrvgf_link',
       'gempak/source/contrib/awc/airmet_vgfbufr/Makefile',
       'gempak/source/contrib/awc/airmet_vgfbufr/airmet_vgfbufr_link',
       'gempak/source/gemlib/da/Makefile',
       'gempak/source/griblib/g2/Makefile',
       'gempak/source/programs/dc/dcgrib2/Makefile',
       'gempak/source/programs/dc/dcigdr/Makefile',
       'gempak/source/programs/dc/dcredbook/Makefile',
       'gempak/source/programs/util/prob2cat/Makefile',
       'gempak/source/driver/active/png/png_link',
       'gempak/source/contrib/awc/gpltln/gpltln_link',
       'gempak/source/contrib/awc/gpanot/gpanot_link',
       'gempak/source/contrib/awc/gdmlev/gdmlev_nc_link',
       'gempak/source/contrib/awc/gdmlev/gdmlev_link',
       'gempak/source/programs/upc/programs/gpnexr2/gpmap_link',
       'gempak/source/gemlib/im/testim_link'].each do |filepath|
        inreplace filepath, {
          /\$(\()?OS_LIB(\))?\/libxslt.a/ => "#{Libxslt.lib}/libxslt.so",
          /\$(\()?OS_INC(\))?\/libxslt/ => "#{Libxml2.inc}/libxslt",
          /\$(\()?OS_LIB(\))?\/libxml2.a/ => "#{Libxml2.lib}/libxml2.so",
          /\$(\()?OS_INC(\))?\/libxml2/ => "#{Libxml2.inc}/libxml2",
          'NETCDFINC         = $(OS_INC)' => "NETCDFINC = #{Netcdf.inc}",
          /\$(\()?OS_LIB(\))?\/libnetcdf.a/ => "#{Netcdf.lib}/libnetcdf.so",
          /\$(\()?GEMOLB(\))?\/libnetcdf.a/ => "#{Netcdf.lib}/libnetcdf.so",
          'ZLIBINC          = $(OS_INC)' => "ZLIBINC = #{Zlib.inc}",
          /\$(\()?OS_LIB(\))?\/libz.a/ => "#{Zlib.lib}/libz.so",
          'PNGINC           = $(OS_INC)' => "PNGINC = #{Libpng.inc}",
          /\$(\()?OS_LIB(\))?\/libpng.a/ => "#{Libpng.lib}/libpng.so",
          /\$(\()?OS_LIB(\))?\/libjasper.a/ => "#{Jasper.lib}/libjasper.so",
          '$(NAWIPS)/os/$(NA_OS)/lib/libjasper.a' => "#{Jasper.lib}/libjasper.so",
          /\$(\()?OS_LIB(\))?\/libbz2.a/ => "#{Bzip2.lib}/libbz2.a",
          /LIBNCEPBUFR\s*=\s*\$\(OS_LIB\)\/libncepBUFR.a/ => "LIBNCEPBUFR = #{Bufrlib.lib}/libbufr.a",
          '$(OS_LIB)/libncepBUFR.a' => "#{Bufrlib.lib}/libbufr.a",
          'JAS_INC=-I$(NAWIPS)/jasper/$(NA_OS)/include' => "JAS_INC = -I#{Jasper.inc}",
          'PNG_INC=-I$(GEMPAK)/source/libpng' => "PNG_INC = -I#{Libpng.inc}"
        }
      end
      inreplace 'gempak/source/driver/active/png/png_compile', {
        '-I$GEMPAK/source/libpng' => "-I#{Libpng.inc}",
      }
      inreplace 'config/Makeinc.common_sav', {
        'ZLIB             = $(GEMOLB)/libz.a' => "ZLIB = #{Zlib.lib}/libz.a"
      }
      # Fix a bug due to use of newer libpng (> 1.2). See https://bugs.launchpad.net/stratagus/+bug/821210.
      inreplace 'gempak/source/driver/active/png/xpng.c', {
        'setjmp(write_ptr->jmpbuf)' => 'setjmp(png_jmpbuf(write_ptr))'
      }
      ['config/Makeinc.common',
       'config/Makeinc.common_sav',
       'config/Makeinc.common_sol',
       'config/Makeinc.linux64_gfortran',
       'config/Makeinc.linux_gfortran'].each do |filepath|
        inreplace filepath, {
          /CC\s*=\s*.*$/ => "CC = #{CompilerStore.compiler(:c).command}",
          /FC\s*=\s*.*$/ => "FC= #{CompilerStore.compiler(:fortran).command}",
        }
      end
      if CompilerStore.compiler(:fortran).vendor == :intel
        ['config/Makeinc.linux64_gfortran', 'config/Makeinc.linux_gfortran'].each do |filepath|
          inreplace filepath, {
            '-fno-second-underscore' => '-assume underscore',
            '-fno-range-check' => '',
            '-fd-lines-as-comments' => ''
          }
        end
        inreplace 'config/Makeinc.common', {
          /LINK.f(\s*=.*)$/ => "LINK.f\\1 -nofor-main",
        }
      end
      System::Shell.append_source_file './Gemenviron.profile'
      run 'make', 'everything'
    end
  end
end
