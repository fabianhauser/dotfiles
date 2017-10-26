execute pathogen#infect()
set background=dark
colorscheme elflord

" Other settings
set ignorecase			" Ignore search case
set autoindent			" Newline with automatic text indent
set ruler			" Show current position
set pastetoggle=<F2>
set ignorecase
set hidden

set tabstop=4
set shiftwidth=4
set softtabstop=4
set expandtab

set listchars="eol:¬,tab:>·,trail:~,extends:>,precedes:<,space:␣"
set grepprg=ack\ -k

" syntastic
" set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0

" Rust
let g:rustfmt_autosave = 1
let g:racer_cmd="~/.cargo/bin/racer"
"let g:racer_experimental_completer = 1
au FileType rust nmap gd <Plug>(rust-def)
au FileType rust nmap gs <Plug>(rust-def-split)
au FileType rust nmap gx <Plug>(rust-def-vertical)
au FileType rust nmap <leader>gd <Plug>(rust-doc)

" Options
filetype plugin indent on
syntax on
