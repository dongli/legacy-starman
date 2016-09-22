module STARMAN
  class Antlr2 < Package
    homepage 'http://www.antlr2.org'
    url 'http://www.antlr2.org/download/antlr-2.7.7.tar.gz'
    sha256 '853aeb021aef7586bda29e74a6b03006bcb565a755c86b66032d8ec31b67dbb9'
    version '2.7.7'

    def install
      inreplace 'lib/cpp/antlr/CharScanner.hpp',
        /^(#include <map>)$/,
        "\\1\n#include <strings.h>\n#include <cstdio>\n"
      args = %W[
        --prefix=#{prefix}
        --disable-debug
        --disable-csharp
        --disable-java
        --disable-python
      ]
      run './configure', *args
      run 'make'
      run 'make', 'install'
    end
  end
end
