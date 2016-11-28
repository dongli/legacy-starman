module STARMAN
  class Nodejs < Package
    url 'https://nodejs.org/dist/v7.2.0/node-v7.2.0.tar.xz'
    sha256 '486d4db7ef659521ad2fafefca877638da07bef61e2aee090207ff52149294fb'
    version '7.2.0'

    label :compiler_agnostic

    depends_on :pkgconfig if needs_build?
    depends_on :openssl
    depends_on :zlib
    depends_on :icu4c

    def install
      System::Xcode.select :xcode_app if OS.mac? and System::Xcode.command_line_tools?
      System::Shell.append 'LDFLAGS', "-L#{Icu4c.lib}"
      args = %W[
        --prefix=#{prefix}
        --without-npm
        --shared-openssl
        --shared-openssl-includes=#{Openssl.inc}
        --shared-openssl-libpath=#{Openssl.lib}
        --shared-zlib
        --shared-zlib-includes=#{Zlib.inc}
        --shared-zlib-libpath=#{Zlib.lib}
        --with-intl=system-icu
      ]
      run './configure', *args
      run 'make', 'install'
    end
  end
end
