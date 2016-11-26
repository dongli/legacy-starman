module STARMAN
  class Gpgme < Package
    url 'https://www.gnupg.org/ftp/gcrypt/gpgme/gpgme-1.7.0.tar.bz2'
    sha256 '71f55fed0f2b3eaf7a606e59772aa645ce3ffff322d361ce359951b3f755cc48'
    version '1.7.0'

    label :compiler_agnostic

    depends_on :gnupg2

    def install
      run './configure', "--prefix=#{prefix}",
                         '--disable-dependency-tracking',
                         '--disable-silent-rules',
                         '--enable-static'
      run 'make'
      run 'make', 'install'
    end
  end
end
