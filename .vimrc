syntax on
set encoding=utf-8
set fileencoding=utf-8
set autoindent
set number
set showmode
set title
set tabstop=4
set incsearch
set hlsearch
set nocompatible
set laststatus=2

if !has('gui-running')
  set t_Co=256
endif

if has('vim_starting')
  set runtimepath+=~/.vim/bundle/neobundle.vim/
  call neobundle#rc(expand('~/.vim/bundle/'))
endif

NeoBundle 'itchyny/lightline.vim'
NeoBundle 'Shougo/unite.vim'
NeoBundle 'Shougo/vimproc'
NeoBundle 'plasticboy/vim-markdown'

filetype plugin indent on

let g:lightline = {
    \ 'colorscheme': 'landscape'
    \ }

let g:unite_source_grep_command = 'ag'
let g:unite_source_grep_default_opts = '--nocolor --nogroup'
let g:unite_source_grep_recursive_opt = ''
let g:unite_source_grep_max_candidates = 200