module STARMAN
  class Gnupg2 < Package
    url 'https://gnupg.org/ftp/gcrypt/gnupg/gnupg-2.0.30.tar.bz2'
    sha256 'e329785a4f366ba5d72c2c678a7e388b0892ac8440c2f4e6810042123c235d71'
    version '2.0.30'

    depends_on :libassuan
    depends_on :libgcrypt
    depends_on :libgpg_error
    depends_on :libiconv
    depends_on :libksba
    depends_on :pinentry
    depends_on :pth
    depends_on :readline

    def install
      if OS.mac?
        ENV['gl_cv_absolute_stdint_h'] = '/Applications/Xcode.app/Contents//Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/usr/include/stdint.h'
      end
      args = %W[
        --prefix=#{prefix}
        --disable-dependency-tracking
        --enable-symcryptrun
        --with-libiconv-prefix=#{Libiconv.prefix}
        --with-readline=#{Readline.prefix}
      ]
      run './configure', *args
      run 'make'
      run 'make', 'check' unless skip_test?
      run 'make', 'install'
    end
  end
end
