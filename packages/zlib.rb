module STARMAN
  class Zlib < Package
    homepage 'http://www.zlib.net/'
    url 'https://github.com/madler/zlib/archive/v1.2.8.tar.gz'
    sha256 'e380bd1bdb6447508beaa50efc653fe45f4edc1dafe11a251ae093e0ee97db9a'
    version '1.2.8'
    filename 'zlib-1.2.8.tar.gz'
    language :c

    def install
      run './configure', "--prefix=#{prefix}"
      inreplace 'Makefile', 'LDSHARED=cc -shared', "LDSHARED=#{CompilerStore.compiler(:c).command} -shared"
      run 'make', 'install'
    end
  end
end
