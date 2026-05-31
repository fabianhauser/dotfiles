{ pkgs, ... }:
{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    extraConfig = ''
      " colorscheme elflord
      set autoindent
      set ruler
      "set pastetoggle=<F2>
      set splitbelow
      set splitright
      set mouse=
      set hidden
      set expandtab

      set tabstop=2
      set softtabstop=2

      set listchars="eol:¬,tab:>·,trail:~,extends:>,precedes:<,space:␣"
      set grepprg=ack\ -k

      set statusline+=%{SyntasticStatuslineFlag()}
      set statusline+=%*

      let g:syntastic_always_populate_loc_list = 1
      let g:syntastic_auto_loc_list = 1
      let g:syntastic_check_on_open = 1
      let g:syntastic_check_on_wq = 0
      let g:syntastic_mode_map = { 'mode': 'passive', 'active_filetypes': [],'passive_filetypes': [] }
      "nnoremap <C-w>E :SyntasticCheck<CR> :SyntasticToggleMode<CR>

      " Rust
      "let g:rustfmt_autosave = 1
      let g:racer_cmd="~/.cargo/bin/racer"
      "let g:racer_experimental_completer = 1
      au FileType rust nmap gd <Plug>(rust-def)
      au FileType rust nmap gs <Plug>(rust-def-split)
      au FileType rust nmap gx <Plug>(rust-def-vertical)
      au FileType rust nmap <leader>gd <Plug>(rust-doc)

      " Typescript
      au BufRead,BufNewFile *.ts   setfiletype typescript

      " Options
      filetype plugin indent on
      syntax on
    '';
    plugins = with pkgs.vimPlugins; [
      vim-sensible
      vim-airline
    ];
  };
  catppuccin.nvim.enable = true;
}
