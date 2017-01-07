module STARMAN
  class Gpp < Package
    homepage 'http://en.nothingisreal.com/wiki/GPP'
    url 'https://files.nothingisreal.com/software/gpp/gpp-2.24.tar.bz2'
    sha256 '9bc2db874ab315ddd1c03daba6687f5046c70fb2207abdcbd55d0e9ad7d0f6bc'

    label :compiler_agnostic
    label :system_first, command: 'gpp'

    def install
      args = %W[
        --disable-debug
        --disable-dependency-tracking
        --prefix=#{prefix}
      ]
      run './configure', *args
      run 'make'
      run 'make', 'check'
      run 'make', 'install'
    end
  end
end
