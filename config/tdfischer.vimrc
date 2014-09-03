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

let g:rbpt_colorpairs = [
    \ ['brown',       'RoyalBlue3'],
    \ ['Darkblue',    'SeaGreen3'],
    \ ['darkgray',    'DarkOrchid3'],
    \ ['darkgreen',   'firebrick3'],
    \ ['darkcyan',    'RoyalBlue3'],
    \ ['darkred',     'SeaGreen3'],
    \ ['darkmagenta', 'DarkOrchid3'],
    \ ['brown',       'firebrick3'],
    \ ['gray',        'RoyalBlue3'],
    \ ['white',       'SeaGreen3'],
    \ ['darkmagenta', 'DarkOrchid3'],
    \ ['Darkblue',    'firebrick3'],
    \ ['darkgreen',   'RoyalBlue3'],
    \ ['darkcyan',    'SeaGreen3'],
    \ ['darkred',     'DarkOrchid3'],
    \ ['red',         'firebrick3'],
    \ ]

au VimEnter * RainbowParenthesesToggle
au VimEnter * AirlineTheme dark
au Syntax * RainbowParenthesesLoadRound
au Syntax * RainbowParenthesesLoadSquare
au Syntax * RainbowParenthesesLoadBraces
au Syntax * RainbowParenthesesLoadChevrons

let g:syntastic_cpp_check_header = 1
let g:syntastic_cpp_compiler_options = '-std=c++11'
let g:airline_powerline_fonts = 1
let &colorcolumn=80
let g:airline#extensions#tmuxline#enabled = 1
set laststatus=2
set background=dark

" Find file in current directory and edit it.
function! Find(name)
  let l:list=system("find . -name '".a:name."' | perl -ne 'print \"$.\\t$_\"'")
" replace above line with below one for gvim on windows
" let l:list=system("find . -name ".a:name." | perl -ne \"print qq{$.\\t$_}\"")
  let l:num=strlen(substitute(l:list, "[^\n]", "", "g"))
  if l:num < 1
    echo "'".a:name."' not found"
    return
  endif
  if l:num != 1
    echo l:list
    let l:input=input("Which ? (CR=nothing)\n")
    if strlen(l:input)==0
      return
    endif
    if strlen(substitute(l:input, "[0-9]", "", "g"))>0
      echo "Not a number"
      return
    endif
    if l:input<1 || l:input>l:num
      echo "Out of range"
      return
    endif
    let l:line=matchstr("\n".l:list, "\n".l:input."\t[^\n]*")
  else
    let l:line=l:list
  endif
  let l:line=substitute(l:line, "^[^\t]*\t./", "", "")
  execute ":e ".l:line
endfunction
command! -nargs=1 Find :call Find("<args>")
augroup CursorLine
  au!
  au VimEnter,WinEnter,BufWinEnter * setlocal cursorline cursorcolumn
  au WinLeave * setlocal nocursorline nocursorcolumn
augroup END
