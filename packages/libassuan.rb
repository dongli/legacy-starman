module STARMAN
  class Libassuan < Package
    url 'https://gnupg.org/ftp/gcrypt/libassuan/libassuan-2.4.3.tar.bz2'
    sha256 '22843a3bdb256f59be49842abf24da76700354293a066d82ade8134bb5aa2b71'
    version '2.4.3'

    depends_on :libgpg_error

    def install
      run './configure', "--prefix=#{prefix}",
                         '--disable-dependency-tracking',
                         '--disable-silent-rules'
      run 'make', 'install'
    end
  end
end
