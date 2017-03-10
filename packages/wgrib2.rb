module STARMAN
  class Wgrib2 < Package
    url 'http://www.ftp.cpc.ncep.noaa.gov/wd51we/wgrib2/wgrib2.tgz.v2.0.6c'
    sha256 '6e54274ab944ed4ab6ab31f8dd377b5c10d107581802cc1eb44c5b157dd52e85'
    version '2.0.6c'
    filename 'wgrib2-2.0.6c.tar.gz'
    language :c, :fortran

    depends_on :jasper
    depends_on :libaec
    depends_on :libpng
    depends_on :netcdf
    depends_on :proj
    depends_on :zlib

    # Make wgrib2 use libraries installed by STARMAN.
    patch :DATA

    def comp_sys
      c_vendor = CompilerStore.compiler(:c).vendor
      f_vendor = CompilerStore.compiler(:fortran).vendor
      if c_vendor == :gnu and f_vendor == :gnu
        'gnu_linux'
      elsif c_vendor == :intel and f_vendor == :intel
        'intel_linux' 
      end
    end

    def install
      inreplace 'makefile', {
        'ifndef COMP_SYS' => "COMP_SYS = #{comp_sys}\nifndef COMP_SYS",
        'wLDFLAGS+=-lproj' => "wLDFLAGS+=-L#{Proj.lib} -lproj",
        'wCPPFLAGS+=-I${proj4}/src' => "wCPPFLAGS+=-I#{Proj.inc}",
        'wLDFLAGS+=-ljasper' => "wLDFLAGS+=-L#{Jasper.lib} -ljasper",
        'wCPPFLAGS+=-I$j/src/libjasper/include' => "wCPPFLAGS+=-I#{Jasper.inc}",
        'wLDFLAGS+=-laec' => "wLDFLAGS+=-L#{Libaec.lib} -laec",
        'wLDFLAGS+=-lnetcdf -lhdf5_hl -lhdf5 -ldl' => "wLDFLAGS+=-L#{Netcdf.lib} -L#{Hdf5.lib} -lnetcdf -lhdf5_hl -lhdf5 -ldl",
        'wCPPFLAGS+=-I${n4}/include -I${h5}/src -I${h5}/hl/src' => "wCPPFLAGS+=-I#{Netcdf.inc} -I#{Hdf5.inc}",
        'wLDFLAGS+=-lpng' => "wLDFLAGS+=-L#{Libpng.lib} -lpng",
        'wCPPFLAGS+=-I$p' => "wCPPFLAGS+=-I#{Libpng.inc}",
        'wLDFLAGS+=-lz' => "wLDFLAGS+=-L#{Zlib.lib} -lz",
        'wCPPFLAGS+=-I$z' => "wCPPFLAGS+=-I#{Zlib.inc}"
      }
      run 'make'
      run 'make', 'lib'
      mkdir_p bin
      cp ['wgrib2/wgrib2', 'aux_progs/gmerge', 'aux_progs/smallest_4', 'aux_progs/smallest_grib2'], bin
      mkdir_p inc
      cp ['lib/wgrib2_api.h', 'lib/wgrib2api.mod', 'lib/wgrib2lowapi.mod'], inc
      mkdir_p lib
      cp ['lib/libgeo.a', 'lib/libipolate.a', 'lib/libwgrib2.a', 'lib/libwgrib2_api.a', 'lib/libwgrib2_small.a'], lib
    end
  end
end

__END__
--- a/makefile  2017-02-16 03:03:58.000000000 +0800
+++ b/makefile  2017-03-08 13:12:28.000000000 +0800
@@ -102,15 +102,15 @@
 #
 
 # Warning do not set both USE_NETCDF3 and USE_NETCDF4 to one
-USE_NETCDF3=1
-USE_NETCDF4=0
+USE_NETCDF3=0
+USE_NETCDF4=1
 USE_REGEX=1
 USE_TIGGE=1
 USE_MYSQL=0
 USE_IPOLATES=1
 USE_UDF=0
 USE_OPENMP=1
-USE_PROJ4=0
+USE_PROJ4=1
 USE_WMO_VALIDATION=0
 DISABLE_TIMEZONE=0
 MAKE_FTN_API=1
@@ -393,11 +393,8 @@
 
 # proj4 library
 ifeq ($(USE_PROJ4),1)
-   proj4:=${cwd}/proj-4.8.0
-   proj4src:=${cwd}/proj-4.8.0.tar.gz
-   proj4lib:=${lib}/libproj.a
    wLDFLAGS+=-lproj
-#   wCPPFLAGS+=-I${proj4}/src
+   wCPPFLAGS+=-I${proj4}/src
    a:=$(shell echo "\#define USE_PROJ4" >> ${CONFIG_H})
 else
    a:=$(shell echo "//\#define USE_PROJ4" >> ${CONFIG_H})
@@ -406,12 +403,6 @@
 # Jasper
 
 ifeq ($(USE_JASPER),1)
-#   jsrc=jasper-fedora19.tgz
-   jsrc=jasper-1.900.1-14ubuntu3.2.debian.tgz
-   j=${cwd}/jasper-1.900.1
-#   jsrc=jasper-1.900.29.tar.gz
-#   j=${cwd}/jasper-1.900.29
-   jlib=${lib}/libjasper.a
    wLDFLAGS+=-ljasper
    wCPPFLAGS+=-I$j/src/libjasper/include
    a:=$(shell echo "\#define USE_JASPER" >> ${CONFIG_H})
@@ -422,35 +413,15 @@
 # AEC
 
 ifeq ($(USE_AEC),1)
-   aecdir=${cwd}/libaec-1.0.0
-   aecsrc=libaec-1.0.0.tar.gz
-   aeclib=${lib}/libaec.a
    wLDFLAGS+=-laec
-   a:=$(shell echo "\#define USE_AEC \"${aecsrc}\"" >> ${CONFIG_H})
+   a:=$(shell echo "\#define USE_AEC" >> ${CONFIG_H})
 else
    a:=$(shell echo "//\#define USE_AEC" >> ${CONFIG_H})
 endif
 
-ifeq ($(USE_NETCDF3),1)
-   n:=${cwd}/netcdf-3.6.3
-   netcdfsrc=netcdf-3.6.3.tar.gz
-   nlib:=${lib}/libnetcdf.a
-   wLDFLAGS+=-lnetcdf
-#   wCPPFLAGS+=-I$n/libsrc
-   a:=$(shell echo "\#define USE_NETCDF3" >> ${CONFIG_H})
-else
-   a:=$(shell echo "//\#define USE_NETCDF3" >> ${CONFIG_H})
-endif
-
 ifeq ($(USE_NETCDF4),1)
-   n4:=${cwd}/netcdf-4.4.1
-   netcdf4src=netcdf-4.4.1.tar.gz
-   n4lib:=${lib}/libnetcdf.a
-   h5:=${cwd}/hdf5-1.8.17
-   hdf5src:=hdf5-1.8.17.tar.gz
-   h5lib:=${lib}/libhdf5.a
    wLDFLAGS+=-lnetcdf -lhdf5_hl -lhdf5 -ldl
-#   wCPPFLAGS+=-I${n4}/include -I${h5}/src -I${h5}/hl/src
+   wCPPFLAGS+=-I${n4}/include -I${h5}/src -I${h5}/hl/src
    a:=$(shell echo "\#define USE_NETCDF4" >> ${CONFIG_H})
 else
    a:=$(shell echo "//\#define USE_NETCDF4" >> ${CONFIG_H})
@@ -498,19 +469,14 @@
 # png 
 
 ifeq ($(USE_PNG),1)
-   p=${cwd}/libpng-1.2.57
-   psrc=${cwd}/libpng-1.2.57.tar.gz
-   plib=${lib}/libpng.a
    wLDFLAGS+=-lpng
-# wCPPFLAGS+=-I$p
+   wCPPFLAGS+=-I$p
    a:=$(shell echo "\#define USE_PNG" >> ${CONFIG_H})
 
 # z
 
-   z=${cwd}/zlib-1.2.11
-   zlib=${lib}/libz.a
    wLDFLAGS+=-lz
-   # wCPPFLAGS+=-I$z
+   wCPPFLAGS+=-I$z
 else
    a:=$(shell echo "//\#define USE_PNG" >> ${CONFIG_H})
 endif
@@ -541,16 +507,16 @@
 w=wgrib2
 prog=$w/wgrib2
 
-all: ${netcdf4src} ${hdf5src} ${prog} aux_progs/gmerge aux_progs/smallest_grib2 aux_progs/smallest_4
+all: ${prog} aux_progs/gmerge aux_progs/smallest_grib2 aux_progs/smallest_4
 
 
-${prog}:        $w/*.c $w/*.h ${jlib} ${aeclib} ${nlib} ${zlib} ${plib} ${h5lib} ${glib} ${n4lib} ${iplib} ${gctpclib} ${proj4lib}
+${prog}:        $w/*.c $w/*.h ${iplib} ${gctpclib}
  cd "$w" && export LDFLAGS="${wLDFLAGS}" && export CPPFLAGS="${wCPPFLAGS}" && ${MAKE}
 
-fast:        $w/*.c $w/*.h ${jlib} ${aeclib} ${nlib} ${zlib} ${plib} ${h5lib} ${glib} ${n4lib} ${iplib} ${gctpclib} ${proj4lib}
+fast:        $w/*.c $w/*.h ${iplib} ${gctpclib}
  cd "$w" && export LDFLAGS="${wLDFLAGS}" && export CPPFLAGS="${wCPPFLAGS}" && ${MAKE} fast
 
-lib:        $w/*.c $w/*.h ${jlib} ${aeclib} ${nlib} ${zlib} ${plib} ${h5lib} ${glib} ${n4lib} ${iplib} ${gctpclib} ${proj4lib}
+lib:        $w/*.c $w/*.h ${iplib} ${gctpclib}
  cd "$w" && export LDFLAGS="${wLDFLAGS}" && export CPPFLAGS="${wCPPFLAGS}" && export FFLAGS="${wFFLAGS}" && ${MAKE} lib
  cp wgrib2/libwgrib2.a lib/libwgrib2_small.a
 ifeq ($(MAKE_FTN_API),1)
@@ -564,47 +530,6 @@
  cp wgrib2/wgrib2_api.h lib/
  cd lib ; touch libwgrib2.a ; rm libwgrib2.a ; ar crsT libwgrib2.a *.a
 
-${jlib}:
- cp ${jsrc}  tmpj.tar.gz
- gunzip -n -f tmpj.tar.gz
- tar -xvf tmpj.tar
- rm tmpj.tar
- cd "$j" && export CC=${CCjasper} && ./configure --without-x --disable-libjpeg --disable-opengl --prefix=${cwd} && ${MAKE} check install
-
-${aeclib}:
- cp ${aecsrc} tmpaec.tar.gz
- gunzip -n -f tmpaec.tar.gz
- tar -xvf tmpaec.tar
- rm tmpaec.tar
- cd "${aecdir}" && export CFLAGS="${wCPPFLAGS}" && ./configure --disable-shared --prefix=${cwd} && ${MAKE} check install
-
-
-${plib}: ${zlib}
- cp ${psrc} tmpp.tar.gz
- gunzip -n -f tmpp.tar.gz
- tar -xvf tmpp.tar
- rm tmpp.tar
-#       for OSX
-#  export LDFLAGS="-L$z" && cd "$p" && export CPPFLAGS="${wCPPFLAGS}" && make -f scripts/makefile.darwin
-#  for everybody else
-#  export LDFLAGS="-L${lib}" && cd "$p" && export CPPFLAGS="${wCPPFLAGS}" && ./configure --disable-shared --prefix=${cwd} && ${MAKE} check install
-#  export LDFLAGS="-L${lib}" && cd "$p" && export CPPFLAGS="${wCPPFLAGS} -DPNG_USER_WIDTH_MAX=200000000L" && ./configure --disable-shared --prefix=${cwd} && ${MAKE} check install
-#  export LDFLAGS="-L${lib}" && cd "$p" && export CFLAGS="${wCPPFLAGS} -DPNG_USER_WIDTH_MAX=200000000L" && ./configure --disable-shared --prefix=${cwd} && ${MAKE} check install
- export LDFLAGS="-L${lib}" && cd "$p" && export CFLAGS="-DPNG_USER_WIDTH_MAX=200000000L" && ./configure --disable-shared --prefix=${cwd} && ${MAKE} check install
-
-${zlib}:
- cp $z.tar.gz tmpz.tar.gz
- gunzip -f tmpz.tar.gz
- tar -xvf tmpz.tar
- rm tmpz.tar
- cd "$z" && export CFLAGS="${wCPPFLAGS}" && ./configure --prefix=${cwd} --static && ${MAKE} install
-#  cd "$z" && export CFLAGS="${wCPPFLAGS}" && ./configure --prefix=${cwd} --static && ${MAKE} check install
-
-${glib}: ${jlib} ${plib} ${zlib}
- touch ${glib}
- rm ${glib}
- cd "$g" && export CPPFLAGS="${wCPPFLAGS}" && ${MAKE} && cp libgrib2c.a ${lib}
-
 ${gctpclib}:
  cp ${gctpcsrc} tmpgctpc.tar.gz
  gunzip -n -f tmpgctpc.tar.gz
@@ -615,41 +540,6 @@
  cp ${gctpc}/source/libgeo.a ${lib}
  cp ${gctpc}/source/proj.h ${cwd}/include/
 
-${proj4lib}:
- cp ${proj4src}  tmpproj4.tar.gz
- gunzip -f tmpproj4.tar.gz
- tar -xvf tmpproj4.tar
- rm tmpproj4.tar
- cd ${proj4} && ./configure --disable-shared --prefix=${cwd} && ${MAKE} check install
-
-${nlib}:
- cp ${netcdfsrc} tmpn.tar.gz
- gunzip -f tmpn.tar.gz
- tar -xvf tmpn.tar
- rm tmpn.tar
- cd $n && export CPPFLAGS="${netcdf3CPPFLAGS}" && ./configure --enable-c-only --prefix=${cwd} && ${MAKE} check install
-
-${n4lib}:  ${zlib} ${netcdf4src} ${h5lib}
- cp ${netcdf4src} tmpn4.tar.gz
- gunzip -n -f tmpn4.tar.gz
- tar -xvf tmpn4.tar
- rm tmpn4.tar
- cd "${n4}" && export CPPFLAGS="${wCPPFLAGS}" && export LDFLAGS="-L${lib}" && export LIBS="-lhdf5 -ldl" && ./configure --disable-fortran --disable-cxx --disable-dap --enable-netcdf-4 --prefix=${cwd} --disable-shared && ${MAKE} install
-
-${netcdf4src}:
- $(error ERROR, get netcdf4 source by "wget ftp://ftp.unidata.ucar.edu/pub/netcdf/netcdf-4.4.1.tar.gz" )
-
-${h5lib}:  ${hdf5src}
- cp ${hdf5src} tmph5.tar.gz
- gunzip -n -f tmph5.tar.gz
- tar -xvf tmph5.tar
- rm tmph5.tar
- cd "${h5}" && export CFLAGS="${hdf5CFLAGS}" && export LDFLAGS="${LDFLAGS}" && ./configure --disable-shared --with-zlib=$z --prefix=${cwd} && ${MAKE} all check install
-
-
-${hdf5src}:
- $(error ERROR, get hdf5 source by "wget https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-1.8.17/src/hdf5-1.8.17.tar.gz" )
-
 ${iplib}:
  cd "${ip}" && export FFLAGS="${wFFLAGS}" && ${MAKE} && cp libipolate.a ${iplib}
 
@@ -670,29 +560,10 @@
  mkdir -p ${cwd}/man && rm -r ${cwd}/man
  cd $w && ${MAKE} clean
  mkdir -p ${gctpc} && rm -rf ${gctpc}
-ifeq ($(USE_PNG),1)
- mkdir -p $z && rm -rf $z
-endif
-ifeq ($(USE_JASPER),1)
- mkdir -p $j && rm -rf $j
-endif
-ifeq ($(USE_AEC),1)
- mkdir -p ${aecdir} && rm -r ${aecdir}
-endif
-ifeq ($(USE_G2CLIB),1)
- mkdir -p $g && cd $g && touch junk.a junk.o && rm *.o *.a
-endif
 ifeq ($(USE_IPOLATES),1)
  echo "cleanup ${ip}"
  mkdir -p ${ip} && touch ${ip}/junk.o ${ip}/junk.a ${ip}/junk.mod && rm ${ip}/*.o ${ip}/*.a ${ip}/*.mod
 endif
-
-ifeq ($(USE_NETCDF3),1)
- mkdir -p $n && rm -rf $n
-endif
-ifeq ($(USE_NETCDF4),1)
- mkdir -p ${n4} && rm -rf ${n4}
-endif
  cd aux_progs && ${MAKE} clean -f gmerge.make
  cd aux_progs && ${MAKE} clean -f smallest_grib2.make
  cd aux_progs && ${MAKE} clean -f smallest_4.make
