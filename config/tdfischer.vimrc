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
au BufNewFile,BufRead COMMIT_EDITMSG set spell
hi clear SpellBad
hi SpellBad cterm=underline

source $BUILDENV_HOME/vim/gobgen.vim

execute pathogen#infect()

au VimEnter * RainbowParenthesesToggle
au Syntax * RainbowParenthesesLoadRound
au Syntax * RainbowParenthesesLoadSquare
au Syntax * RainbowParenthesesLoadBraces
au Syntax * RainbowParenthesesLoadChevrons

let g:syntastic_cpp_check_header = 1
let g:syntastic_cpp_compiler_options = '-std=c++11'
let g:airline_powerline_fonts = 1
