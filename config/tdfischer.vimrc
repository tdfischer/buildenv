call pathogen#infect('lib/flake8')
syntax on
filetype plugin indent on
set smartindent
set tabstop=2
set softtabstop=2
set shiftwidth=2
set expandtab
set number
autocmd BufRead *.vala,*.vapi set efm=%f:%l.%c-%[%^:]%#\ %t%[%^:]%#:\ %m
au BufRead,BufNewFile *.vala,*.vapi setfiletype vala
set tw=80
