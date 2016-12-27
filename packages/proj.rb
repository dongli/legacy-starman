module STARMAN
  class Proj < Package
    url 'http://download.osgeo.org/proj/proj-4.9.3.tar.gz'
    sha256 '6984542fea333488de5c82eea58d699e4aff4b359200a9971537cd7e047185f7'
    version '4.9.3'

    def install
      args = %W[
        --prefix=#{prefix}
        --disable-dependency-tracking
      ]
      run './configure', *args
      run 'make', 'install'
    end
  end
end
