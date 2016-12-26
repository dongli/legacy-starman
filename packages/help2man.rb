module STARMAN
  class Help2man < Package
    url 'https://ftpmirror.gnu.org/help2man/help2man-1.47.4.tar.xz'
    sha256 'd4ecf697d13f14dd1a78c5995f06459bff706fd1ce593d1c02d81667c0207753'
    version '1.47.4'

    label :compiler_agnostic

    def install
      run './configure', "--prefix=#{prefix}"
      run 'make', 'install'
    end
  end
end
