module STARMAN
  class Vim_plug < Package
    url 'https://github.com/junegunn/vim-plug/archive/d5e9f91c7baae9f17a68c093500d51e478cf7f50.zip'
    sha256 '37041c5c8bc696e84e1fb208c3cb0ad5b9add2c9e58fb3759c4811771a4b7d07'
    version 'd5e9f91'
    filename 'vim-plug-d5e9f91.zip'

    label :compiler_agnostic

    depends_on :vim

    def install
      mkdir_p "#{prefix}/autoload"
      mkdir_p "#{persist}/plugged"
      cp 'plug.vim', "#{prefix}/autoload"
    end

    def post_install
      vimrc = "#{ENV['HOME']}/.vimrc"
      if not File.exist? vimrc or File.read(vimrc).include?(/" +++ Plug.vim settings added by STARMAN +++/)
        append_file "#{ENV['HOME']}/.vimrc", <<-EOT.keep_indent
          " +++ Plug.vim settings added by STARMAN +++
          set runtimepath+=#{prefix}

          call plug#begin('#{persist}/plugged')

          Plug 'Shougo/neocomplete.vim'
          Plug 'Shougo/neosnippet.vim'
          Plug 'Shougo/neosnippet-snippets'
          " Add your favorite plugins here, and run :PlugInstall

          call plug#end()

          " +++ Neocomplete.vim settings +++
          let g:neocomplete#enable_at_startup = 1
          let g:neocomplete#enable_smart_case = 1
          inoremap <expr><Left>  neocomplete#close_popup() . "\<Left>"
          inoremap <expr><Right> neocomplete#close_popup() . "\<Right>"
          inoremap <expr><Up>    neocomplete#close_popup() . "\<Up>"
          inoremap <expr><Down>  neocomplete#close_popup() . "\<Down>"
          imap <expr><TAB> neosnippet#expandable_or_jumpable() ?
            \ "\<Plug>(neosnippet_expand_or_jump)"
            \: pumvisible() ? "\<C-n>" : "\<TAB>"
          smap <expr><TAB> neosnippet#expandable_or_jumpable() ?
            \ "\<Plug>(neosnippet_expand_or_jump)"
            \: "\<TAB>"
        EOT
        CLI.report_notice "Run #{CLI.blue ':PlugInstall'} in VIM."
      end
    end
  end
end
