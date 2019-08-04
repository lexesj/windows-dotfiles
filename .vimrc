" Windows
if has('win32')
  call plug#begin('~/vimfiles/plugged')
endif

" Unix
if has('unix')
  call plug#begin('~/.vim/plugged')
endif
  Plug 'morhetz/gruvbox'
  Plug 'ARM9/arm-syntax-vim'
  Plug 'tpope/vim-surround'
  Plug 'tpope/vim-commentary'
  Plug 'tpope/vim-repeat'
  Plug 'tpope/vim-vinegar'
  Plug 'tpope/vim-fugitive'
  Plug 'tpope/vim-sleuth'
  Plug 'vim-airline/vim-airline'
  Plug 'mhinz/vim-signify'
  Plug 'jiangmiao/auto-pairs'
  Plug 'dense-analysis/ale'
call plug#end()

set number
set relativenumber
set clipboard=unnamed
set hlsearch
set backspace=indent,eol,start
set encoding=utf-8

" File aware auto-completion
filetype plugin on
set omnifunc=syntaxcomplete#Complete

" Finding files
set path+=**
set wildmenu

" Gruvbox
set termguicolors
set bg=dark
colorscheme gruvbox

" ARM syntax
au BufNewFile,BufRead *.s,*.S set filetype=arm
autocmd FileType arm setlocal commentstring=;\ %s
autocmd FileType processing setlocal commentstring=//\ %s

" Use <C-L> to clear the highlighting of :set hlsearch.
if maparg('<C-L>', 'n') ==# ''
  nnoremap <silent> <C-L> :nohlsearch<C-R>=has('diff')?'<Bar>diffupdate':''<CR><CR><C-L>
endif

" Python
let g:python3_host_prog='C:\Users\lexes\AppData\Local\Programs\Python\Python37-32\python.exe'
let g:python_host_prog='C:\Users\lexes\AppData\Local\Programs\Python\Python37-32\python.exe'

" Terminal
if has('nvim')
  tnoremap <C-c> <C-\><C-n>
endif

" vim-signify
let g:signify_realtime = 1
