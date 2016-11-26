module STARMAN
  class Libmetalink < Package
    url 'https://launchpad.net/libmetalink/trunk/libmetalink-0.1.3/+download/libmetalink-0.1.3.tar.xz'
    sha256 '86312620c5b64c694b91f9cc355eabbd358fa92195b3e99517504076bf9fe33a'
    version '0.1.3'

    def install
      run './configure', "--prefix=#{prefix} --disable-dependency-tracking"
      run 'make', 'install'
    end
  end
end
