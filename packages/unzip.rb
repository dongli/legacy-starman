module STARMAN
  class Unzip < Package
    url 'https://jaist.dl.sourceforge.net/project/infozip/UnZip%206.x%20%28latest%29/UnZip%206.0/unzip60.tar.gz'
    sha256 '036d96991646d0449ed0aa952e4fbe21b476ce994abc276e49d30e686708bd37'
    version '6.0'

    label :compiler_agnostic
    label :system_first, command: 'unzip'

    def install
      cp 'unix/Makefile', '.'
      run 'make', 'generic'
      mkdir_p bin
      mv ['funzip', 'unzip'], bin
    end
  end
end
