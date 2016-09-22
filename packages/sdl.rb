module STARMAN
  class Sdl < Package
    homepage 'https://www.libsdl.org/'
    url 'https://www.libsdl.org/release/SDL2-2.0.4.tar.gz'
    sha256 ''
    version '2.0.4'

    def install
      args = %W[
        --prefix=#{prefix}
        --disable-nasm
        --without-x
      ]
      args << '--disable-assembly' if CompilerStore.compiler(:c).vendor == :llvm
      run './configure', *args
      run 'make', 'install'
      FileUtils.cp Dir.glob['src/main/macosx/*'], libexec if OS.mac?
    end
  end
end
