module STARMAN
  class Readline < Package
    homepage 'https://cnswww.cns.cwru.edu/php/chet/readline/rltop.html'
    url 'http://ftpmirror.gnu.org/readline/readline-6.3.tar.gz'
    sha256 '56ba6071b9462f980c5a72ab0023893b65ba6debb4eeb475d7a563dc65cafd43'
    version '6.3.8'

    compatible_with '10.11' if OS.mac? and OS.version =~ '10.12'

    def install
      run './configure', "--prefix=#{prefix}", '--enable-multibyte'
      run 'make', 'install'
    end
  end
end
