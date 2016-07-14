module STARMAN
  class Dejagnu < Package
    homepage 'https://www.gnu.org/software/dejagnu/'
    url 'https://ftp.gnu.org/pub/gnu/dejagnu/dejagnu-1.6.tar.gz'
    sha256 '00b64a618e2b6b581b16eb9131ee80f721baa2669fa0cdee93c500d1a652d763'
    version '1.6'

    label :compiler_agnostic

    def install
      args = %W[
        --prefix=#{prefix}
        --disable-debug
        --disable-dependency-tracking
      ]
      run './configure', *args
      run 'make', 'check'
      run 'make', 'install'
    end
  end
end
