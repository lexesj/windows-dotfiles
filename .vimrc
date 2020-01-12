call plug#begin('~/.vim/plugged')

  " QOL
  Plug 'tpope/vim-surround'
  Plug 'tpope/vim-commentary'
  Plug 'tpope/vim-repeat'
  Plug 'tpope/vim-vinegar'
  Plug 'tpope/vim-fugitive'
  Plug 'tpope/vim-sleuth'
  Plug 'mhinz/vim-signify'
  Plug 'jiangmiao/auto-pairs'
  Plug 'christoomey/vim-tmux-navigator'
  Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
  Plug 'junegunn/fzf.vim'

  " UI changes
  Plug 'vim-airline/vim-airline'
  Plug 'morhetz/gruvbox'

  " Syntax
  Plug 'dense-analysis/ale'
  Plug 'ARM9/arm-syntax-vim'

  " Autocomplete
  Plug 'ncm2/ncm2'
  Plug 'roxma/nvim-yarp'
  Plug 'ncm2/ncm2-bufword'
  Plug 'ncm2/ncm2-path'
  Plug 'ncm2/ncm2-jedi'

  " Autoformat
  Plug 'google/vim-maktaba'
  Plug 'google/vim-codefmt'
  Plug 'google/vim-glaive'

  " LaTex
  Plug 'lervag/vimtex'

call plug#end()
call glaive#Install()
Glaive codefmt plugin[mappings]
let g:dir = "java -jar " . $HOME . "/.vim/formatters/google-java-format-1.7-all-deps.jar"
Glaive codefmt google_java_executable=`g:dir`

set number
set relativenumber
set clipboard+=unnamedplus
set hlsearch
set backspace=indent,eol,start
set encoding=utf-8
set colorcolumn=80

autocmd BufWritePre * :%s/\v\s+$//e

" Spellcheck
set complete+=kspell
augroup spellGroup
    autocmd!
    autocmd BufRead,BufNewFile *.md setlocal spell spelllang=en_gb
    autocmd BufRead,BufNewFile *.tex setlocal spell spelllang=en_gb
augroup END

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
if maparg('<C-N>', 'n') ==# ''
  nnoremap <silent> <C-N> :nohlsearch<C-R>=has('diff')?'<Bar>diffupdate':''<CR><CR><C-L>
endif

" vim-signify
let g:signify_realtime = 1

" Terminal
if has('nvim')
  tnoremap <C-c> <C-\><C-n>
endif

" Python
if has('win32')
  let g:python3_host_prog='C:\Users\lexes\AppData\Local\Programs\Python\Python37-32\python.exe'
  let g:python_host_prog='C:\Users\lexes\AppData\Local\Programs\Python\Python37-32\python.exe'
endif

" NCM2
if has('nvim')
  augroup NCM2
    autocmd!
    " enable ncm2 for all buffers
    autocmd BufEnter * call ncm2#enable_for_buffer()
    " :help Ncm2PopupOpen for more information
    set completeopt=noinsert,menuone,noselect
    " When the <Enter> key is pressed while the popup menu is visible, it only
    " hides the menu. Use this mapping to close the menu and also start a new line.
    inoremap <expr> <CR> (pumvisible() ? "\<c-y>\<cr>" : "\<CR>")
    " uncomment this block if you use vimtex for LaTex
    autocmd Filetype tex call ncm2#register_source({
              \ 'name': 'vimtex',
              \ 'priority': 8,
              \ 'scope': ['tex'],
              \ 'mark': 'tex',
              \ 'word_pattern': '\w+',
              \ 'complete_pattern': g:vimtex#re#ncm2,
              \ 'on_complete': ['ncm2#on_complete#omni', 'vimtex#complete#omnifunc'],
              \ })
  augroup END
endif

" Ale
let g:ale_linters = {'python': ['flake8']}

" Autoformat

augroup autoformat_settings
  autocmd FileType bzl AutoFormatBuffer buildifier
  autocmd FileType c,cpp,proto,javascript AutoFormatBuffer clang-format
  autocmd FileType dart AutoFormatBuffer dartfmt
  autocmd FileType go AutoFormatBuffer gofmt
  autocmd FileType gn AutoFormatBuffer gn
  autocmd FileType html,css,sass,scss,less,json AutoFormatBuffer js-beautify
  " autocmd FileType java AutoFormatBuffer clang-format
  autocmd FileType java AutoFormatBuffer google-java-format
  autocmd FileType python AutoFormatBuffer autopep8
  autocmd FileType vue AutoFormatBuffer prettier
augroup END
