module STARMAN
  class Nodejs < Package
    url 'https://github.com/nodejs/node/archive/v7.8.0.tar.gz'
    sha256 'b5836069ffaa84d8000ea579b8b1f97602eaa8c4883153f718758a4f3da9a4d8'
    version '7.8.0'
    filename 'nodejs-7.8.0.tar.gz'

    label :compiler_agnostic

    depends_on :pkgconfig if needs_build?
    depends_on :openssl, version: '1.0.2k'
    depends_on :zlib
    depends_on :icu4c

    def install
      System::Xcode.select :xcode_app if OS.mac? and System::Xcode.command_line_tools?
      System::Shell.append 'LDFLAGS', "-Wl,-rpath,#{Openssl.lib}"
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
