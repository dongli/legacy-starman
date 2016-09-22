module STARMAN
  class Swig < Package
    homepage 'http://www.swig.org/'
    url 'https://downloads.sourceforge.net/project/swig/swig/swig-3.0.10/swig-3.0.10.tar.gz'
    sha256 '2939aae39dec06095462f1b95ce1c958ac80d07b926e48871046d17c0094f44c'
    version '3.0.10'

    label :compiler_agnostic

    depends_on :pcre

    def install
      args = %W[
        --prefix=#{prefix}
        --disable-dependency-tracking
      ]
      run './configure', *args
      run 'make'
      run 'make', 'install'
    end
  end
end
