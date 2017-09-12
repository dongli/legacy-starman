module STARMAN
  class Szip < Package
    homepage 'https://www.hdfgroup.org/HDF5/release/obtain5.html#extlibs'
    url 'https://support.hdfgroup.org/ftp/lib-external/szip/2.1.1/src/szip-2.1.1.tar.gz'
    sha256 '897dda94e1d4bf88c91adeaad88c07b468b18eaf2d6125c47acac57e540904a9'
    version '2.1.1'
    language :c

    def install
      run './configure', '--disable-debug', '--disable-dependency-tracking',
                         "--prefix=#{prefix}"
      run 'make', 'install'
    end
  end
end
