module STARMAN
  class Lua < Package
    url 'http://www.lua.org/ftp/lua-5.3.3.tar.gz'
    sha256 '5113c06884f7de453ce57702abaac1d618307f33f6789fa870e87a59d772aca2'
    version '5.3.3'

    label :compiler_agnostic

    depends_on :readline
    depends_on :ncurses

    def install
      inreplace 'src/Makefile', {
        /^\s*CC\s*=.*$/ => "CC = #{CompilerStore.compiler(:c).command}",
        /^\s*CFLAGS\s*=(.*)$/ => "CFLAGS = \\1 -I#{Readline.inc} -I#{Ncurses.inc}",
        /^\s*LDFLAGS\s*=(.*)$/ => "LDFLAGS = \\1 -L#{Readline.lib} -L#{Ncurses.lib}",
        /^\s*LIBS\s*=(.*)$/ => "LIBS = \\1 -lncursesw"
      }
      inreplace 'src/luaconf.h', {
        /#define LUA_ROOT.*/ => "#define LUA_ROOT \"#{prefix}\""
      }
      if OS.linux?
        platform = 'linux'
      elsif OS.mac?
        platform = 'macosx'
      else
        platform = 'generic'
      end
      run 'make', platform, "INSTALL_TOP=#{prefix}", "INSTALL_MAN=#{man}/man1"
      run 'make', 'install', "INSTALL_TOP=#{prefix}", "INSTALL_MAN=#{man}/man1"
      mkdir_p "#{lib}/pkgconfig"
      File.open("#{lib}/pkgconfig/lua.pc", 'w') do |file|
        file << <<-EOT.keep_indent
          V= 5.3
          R= 5.3.3
          prefix=#{prefix}
          INSTALL_BIN= ${prefix}/bin
          INSTALL_INC= ${prefix}/include
          INSTALL_LIB= ${prefix}/lib
          INSTALL_MAN= ${prefix}/share/man/man1
          INSTALL_LMOD= ${prefix}/share/lua/${V}
          INSTALL_CMOD= ${prefix}/lib/lua/${V}
          exec_prefix=${prefix}
          libdir=${exec_prefix}/lib
          includedir=${prefix}/include
          
          Name: Lua
          Description: An Extensible Extension Language
          Version: 5.3.3
          Requires:
          Libs: -L${libdir} -llua -lm
          Cflags: -I${includedir}
        EOT
      end
    end
  end
end
