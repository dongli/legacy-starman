module STARMAN
  class Libgpg_error < Package
    url 'https://gnupg.org/ftp/gcrypt/libgpg-error/libgpg-error-1.25.tar.bz2'
    sha256 'f628f75843433b38b05af248121beb7db5bd54bb2106f384edac39934261320c'
    version '1.25'

    def install
      args = %W[
        --prefix=#{prefix}
        --disable-dependency-tracking
        --disable-silent-rules
        --enable-static
      ]
      run './configure', *args
      run 'make', 'install'
    end
  end
end
