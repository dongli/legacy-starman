module STARMAN
  class Expat < Package
    homepage 'http://expat.sourceforge.net'
    url 'https://downloads.sourceforge.net/project/expat/expat/2.2.0/expat-2.2.0.tar.bz2'
    sha256 'd9e50ff2d19b3538bd2127902a89987474e1a4db8e43a66a4d1a712ab9a504ff'
    version '2.2.0'

    label :system_conflict if OS.mac?

    def install
      run './configure', "--prefix=#{prefix}"
      run 'make', 'install'
    end
  end
end
