module STARMAN
  class Flex < Package
    url 'https://github.com/westes/flex/releases/download/v2.6.2/flex-2.6.2.tar.gz'
    sha256 '9a01437a1155c799b7dc2508620564ef806ba66250c36bf5f9034b1c207cb2c9'
    version '2.6.2'

    label :compiler_agnostic
    label :system_first, command: 'flex'

    depends_on :gettext
    depends_on :help2man if needs_build?
    depends_on :libiconv
    depends_on :m4 if needs_build?

    def install
      args = %W[
        --prefix=#{prefix}
        --disable-dependency-tracking
        --disable-silent-rules
        --enable-shared
        --with-libiconv-prefix=#{Libiconv.prefix}
        --with-libintl-prefix=#{Gettext.prefix}
      ]
      run './configure', *args
      run 'make', 'install'
    end
  end
end
