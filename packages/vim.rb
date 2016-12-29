module STARMAN
  class Vim < Package
    url 'https://github.com/vim/vim/archive/v8.0.0134.tar.gz'
    sha256 '1b3e3e7d187eed55cbdb0a1dae6b8f3b885005fbae84222420877d7afa3b2310'
    version '8.0.0134'
    filename 'vim-8.0.0134.tar.gz'

    label :compiler_agnostic

    option 'with-lua-interp', {
      desc: 'Build Lua scripting support.',
      accept_value: { boolean: true }
    }
    option 'with-python3-interp', {
      desc: 'Build Python3 scripting support.',
      accept_value: { boolean: true }
    }
    option 'with-ruby-interp', {
      desc: 'Build Ruby scripting support.',
      accept_value: { boolean: true }
    }

    depends_on :lua if with_lua_interp?
    depends_on :ncurses
    depends_on :python3 if with_python3_interp?
    depends_on :ruby if with_ruby_interp?

    def install
      args = %W[
        --prefix=#{prefix}
        --enable-multibyte
        --enable-gui=no
        --enable-cscope
        --without-x
        --with-tlib=ncurses
        --with-features=huge
      ]
      if with_lua_interp?
        args << '--enable-luainterp=yes'
        args << "--with-lua-prefix='#{Lua.prefix}'"
      end
      if with_python3_interp?
        args << '--enable-python3interp=yes'
        args << "--with-python3-config-dir='#{Python3.bin}'"
      end
      if with_ruby_interp?
        args << '--enable-rubyinterp=yes'
        args << "--with-ruby-command='#{Ruby.bin}/ruby'"
      end
      run './configure', *args
      run 'make'
      run 'make', 'install', "prefix=#{prefix}", 'STRIP=true'
      ln_s "#{bin}/vim", "#{bin}/vi"
    end
  end
end
