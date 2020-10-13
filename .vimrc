colorscheme ron
set encoding=utf-8
set fileencoding=utf-8
set autoindent
set number
set ruler
set showmode
set expandtab
set tabstop=2
set softtabstop=2
set shiftwidth=2
set incsearch
set hlsearch
set laststatus=2
set backspace=indent,eol,start

if &compatible
  set nocompatible
endif

if !has('gui-running')
  set t_Co=256
endif

filetype plugin indent on
syntax enable

highlight clear SignColumn

set splitbelow

" generate shebang automatically
augroup Shebang
  autocmd BufNewFile *.py 0put =\"#!/usr/bin/env python\<nl># -*- coding: utf-8 -*-\<nl>\"|$
  autocmd BufNewFile *.rb 0put =\"#!/usr/bin/env ruby\<nl># -*- coding: utf-8 -*-\<nl>\"|$
  autocmd BufNewFile *.sh 0put =\"#!/bin/bash\<nl>\"|$
augroup END

" make executable if shebang
autocmd BufWritePost * :call AddExecmod()
function AddExecmod()
    let line = getline(1)
    if strpart(line, 0, 2) == "#!"
        call system("chmod +x ". expand("%"))
    endif
endfunction

autocmd InsertLeave * set nopaste
