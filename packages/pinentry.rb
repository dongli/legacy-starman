module STARMAN
  class Pinentry < Package
    url 'https://gnupg.org/ftp/gcrypt/pinentry/pinentry-0.9.7.tar.bz2'
    sha256 '6398208394972bbf897c3325780195584682a0d0c164ca5a0da35b93b1e4e7b2'
    version '0.9.7'

    depends_on :pkgconfig if needs_build?
    depends_on :libgpg_error
    depends_on :libassuan

    def install
      args = %W[
        --prefix=#{prefix}
        --disable-dependency-tracking
        --disable-silent-rules
        --disable-pinentry-qt
        --disable-pinentry-qt5
        --disable-pinentry-gnome3
        --disable-pinentry-gtk2
      ]
      run './configure', *args
      run 'make', 'install'
    end
  end
end
