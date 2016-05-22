module STARMAN
  class Szip < Package
    homepage 'https://www.hdfgroup.org/HDF5/release/obtain5.html#extlibs'
    url 'https://www.hdfgroup.org/ftp/lib-external/szip/2.1/src/szip-2.1.tar.gz'
    sha256 'a816d95d5662e8279625abdbea7d0e62157d7d1f028020b1075500bf483ed5ef'
    version '2.1'
    languages :c

    def install
      run './configure', '--disable-debug', '--disable-dependency-tracking',
                         "--prefix=#{prefix}"
      run 'make', 'install'
    end
  end
end
