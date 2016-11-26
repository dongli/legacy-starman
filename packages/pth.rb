module STARMAN
  class Pth < Package
    url 'https://ftpmirror.gnu.org/pth/pth-2.0.7.tar.gz'
    sha256 '72353660c5a2caafd601b20e12e75d865fd88f6cf1a088b306a3963f0bc77232'
    version '2.0.7'

    def install
      run './configure', "--prefix=#{prefix}"
      run 'make'
      run 'make', 'test' unless skip_test?
      run 'make', 'install'
    end
  end
end
