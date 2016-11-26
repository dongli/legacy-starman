module STARMAN
  class Libksba < Package
    url 'https://gnupg.org/ftp/gcrypt/libksba/libksba-1.3.5.tar.bz2'
    sha256 '41444fd7a6ff73a79ad9728f985e71c9ba8cd3e5e53358e70d5f066d35c1a340'
    version '1.3.5'

    depends_on :libgpg_error

    def install
      run './configure', "--prefix=#{prefix}",
                         '--disable-dependency-tracking',
                         '--disable-silent-rules'
      run 'make', 'install'
    end
  end
end
