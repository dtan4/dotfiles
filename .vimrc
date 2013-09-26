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

filetype plugin indent on
