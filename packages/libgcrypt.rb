module STARMAN
  class Libgcrypt < Package
    url 'https://gnupg.org/ftp/gcrypt/libgcrypt/libgcrypt-1.7.3.tar.bz2'
    sha256 'ddac6111077d0a1612247587be238c5294dd0ee4d76dc7ba783cc55fb0337071'
    version '1.7.3'

    depends_on :libgpg_error

    def install
      args = %W[
        --prefix=#{prefix}
        --disable-dependency-tracking
        --disable-silent-rules
        --enable-static
        --disable-asm
        --with-libgpg-error-prefix=#{Libgpg_error.prefix}
      ]
      run './configure', *args
      run 'make'
      run 'install_name_tool', '-change',
                               "#{lib}/libgcrypt.20.dylib",
                               "#{pwd}/src/.libs/libgcrypt.20.dylib",
                               "#{pwd}/tests/.libs/random"
      run 'make', 'check' unless skip_test?
      run 'make', 'install'
    end
  end
end
