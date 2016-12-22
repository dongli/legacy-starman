module STARMAN
  class Openpam < Package
    url 'http://jaist.dl.sourceforge.net/project/openpam/openpam/Ourouparia/openpam-20140912.tar.gz'
    sha256 '82bc29397fa68ce49742618e0affdaa9abd4341d9ffbe607f9b10cdf1242bc87'
    version '20140912'

    def install
      args = %W[
        --prefix=#{prefix}
        --disable-dependency-tracking
      ]
      run './configure', *args
      run 'make'
      run 'make', 'check'
      run 'make', 'install'
    end
  end
end
