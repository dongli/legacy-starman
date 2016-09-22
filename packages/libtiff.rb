module STARMAN
  class Libtiff < Package
    homepage 'http://www.remotesensing.org/libtiff/'
    url 'http://download.osgeo.org/libtiff/tiff-4.0.6.tar.gz'
    sha256 '4d57a50907b510e3049a4bba0d7888930fdfc16ce49f1bf693e5b6247370d68c'
    version '4.0.6'

    label :system_conflict if OS.mac?

    depends_on :libjpeg
    depends_on :xz

    patch do |files|
      url 'https://mirrors.ocf.berkeley.edu/debian/pool/main/t/tiff/tiff_4.0.6-2.debian.tar.xz'
      sha256 '82a0ef3f713d2a22d40b9be71fd121b9136657d313ae6b76b51430302a7b9f8b'
      files << 'patches/01-CVE-2015-8665_and_CVE-2015-8683.patch'
      files << 'patches/02-fix_potential_out-of-bound_writes_in_decode_functions.patch'
      files << 'patches/03-fix_potential_out-of-bound_write_in_NeXTDecode.patch'
      files << 'patches/04-CVE-2016-5314_CVE-2016-5316_CVE-2016-5320_CVE-2016-5875.patch'
      files << 'patches/05-CVE-2016-6223.patch'
      files << 'patches/06-CVE-2016-5321.patch'
      files << 'patches/07-CVE-2016-5323.patch'
    end

    def install
      args = %W[
        --disable-dependency-tracking
        --prefix=#{prefix}
        --without-x
        --with-jpeg-include-dir=#{Libjpeg.inc}
        --with-jpeg-lib-dir=#{Libjpeg.lib}
        --with-lzma-include-dir=#{Xz.inc}
        --with-lzma-lib-dir=#{Xz.lib}
      ]
      run './configure', *args
      run 'make', 'install'
    end
  end
end
