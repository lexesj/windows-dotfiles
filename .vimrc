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
call plug#end()

set number
set relativenumber
set clipboard=unnamed
set hlsearch
set backspace=indent,eol,start
set encoding=utf-8

" Finding files
set path+=**
set wildmenu

" IdeaVim tpope plugin
" set surround

" Gruvbox
set termguicolors
set bg=dark
colorscheme gruvbox

" ARM syntax
au BufNewFile,BufRead *.s,*.S set filetype=arm
autocmd FileType arm setlocal commentstring=;\ %s

" Vwrapper
" set nonumber

" processing
au BufNewFile,BufRead *.pde set filetype=java

" Use <C-L> to clear the highlighting of :set hlsearch.
if maparg('<C-L>', 'n') ==# ''
  nnoremap <silent> <C-L> :nohlsearch<C-R>=has('diff')?'<Bar>diffupdate':''<CR><CR><C-L>
endif
