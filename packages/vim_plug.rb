module STARMAN
  class Vim_plug < Package
    url 'https://github.com/junegunn/vim-plug/archive/d5e9f91c7baae9f17a68c093500d51e478cf7f50.zip'
    sha256 '37041c5c8bc696e84e1fb208c3cb0ad5b9add2c9e58fb3759c4811771a4b7d07'
    version 'd5e9f91'
    filename 'vim-plug-d5e9f91.zip'

    label :compiler_agnostic

    depends_on :vim

    resource :neocomplete do

    end

    def install
      mkdir_p "#{prefix}/autoload"
      mkdir_p "#{persist}/plugged"
      cp 'plug.vim', "#{prefix}/autoload"
      append_file "#{ENV['HOME']}/.vimrc", <<-EOT.keep_indent
        " Added by STARMAN
        set runtimepath+=#{prefix}

        call plug#begin('#{persist}/plugged')

        Plug 'Shougo/neocomplete.vim'
        " Add your favorite plugins here, and run :PlugInstall

        call plug#end()
      EOT
    end
  end
end
