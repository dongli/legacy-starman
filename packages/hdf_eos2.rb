module STARMAN
  class Hdf_eos2 < Package
    url 'ftp://edhs1.gsfc.nasa.gov/edhs/hdfeos/latest_release/HDF-EOS2.19v1.00.tar.Z'
    sha256 '3fffa081466e85d2b9436d984bc44fe97bbb33ad9d8b7055a322095dc4672e31'
    version '2.19v1.00'

    depends_on :hdf4
    depends_on :libjpeg
    depends_on :szip
    depends_on :zlib

    def install
      args = %W[
        --prefix=#{prefix}
        --with-hdf4=#{Hdf4.prefix}
        --with-zlib=#{Zlib.prefix}
        --with-szlib=#{Szip.prefix}
        --with-jpeg=#{Libjpeg.prefix}
        CC='#{Hdf4.bin}/h4cc -Df2cFortran'
      ]
      run './configure', *args
      run 'make'
      run 'make', 'install'
      work_in 'include' do
        run 'make', 'install'
      end
    end
  end
end
