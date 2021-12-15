"
" Change the <Leader> key to a SPACZE
"
let mapleader = "\<Space>"

:let loaded_matchparen = 1
:set scrolloff=2
:set nowrapscan
:set nowrap
:colorscheme elflord
":set background=dark
:hi special ctermfg=magenta
:set modeline
:set statusline=%F\ %m%=col:%c\ \ line:%l/%L\ \ --%p%%--\ 
:set laststatus=2

"
" display tabs, trailing spaces and non-breaking spaces
" as special chars (from Damian Conway OSCON 2013)
"
:exec "set listchars=tab:\uBB\uBB,trail:\uB7,nbsp:~"
:set list


" Turn off bell
:set vb t_vb=
silent!  set belloff=all

"highlight ExtraWhitespace ctermbg=red guibg=red
"match ExtraWhitespace /\s\+$/
"autocmd BufWinEnter * match ExtraWhitespace /\s\+$/
"autocmd InsertEnter * match ExtraWhitespace /\s\+\%#\@<!$/
"autocmd InsertLeave * match ExtraWhitespace /\s\+$/
"autocmd BufWinLeave * call clearmatches()

"
" vim can update the title in the tmux status line
"
if exists('$TMUX')
  autocmd BufEnter * call system("tmux rename-window '" . expand("%:t") . "'")
  autocmd VimLeave * call system("tmux setw automatic-rename")
  set t_ts=]2;
  set t_fs=\\
  set title
endif

"-------------------------------------------------------------------------------------------------------
"
" Functions to clean up code by aligning the ':', '=' or 'AS' character
" on each line into a column.
"

function! IndentColLines( char ) range
  let s:mcol   = 1
  let s:lineno = a:firstline

  " Loop through the lines in the range to find the max col
  while s:lineno <= a:lastline
    let s:line = getline( s:lineno )
    let s:cidx = stridx( s:line, a:char )   " Find the index of the first char on the line
    let s:col  = s:cidx + 1                 " Need to add 1 because index is 0-based
    if s:cidx > 0
      " If the char before the colon is non-blank, add 1
      if strpart( s:line, s:cidx - 1, 1 ) != ' '
        let s:col = s:col + 1
      endif
    endif
    let s:mcol  = max( [ s:col, s:mcol ] )
    let s:lineno = s:lineno + 1
  endwhile
  "
  " Run the IndentCol function using the original range and passing
  " the max col
  "
  execute a:firstline . "," . a:lastline . 'call IndentColLine( a:char, s:mcol )'
endfunction



function! IndentColLine( char, col ) range
  let s:lineno    = a:firstline
  let s:repl_char = ' ' . a:char

  while s:lineno <= a:lastline
    let s:line = getline(s:lineno)
    let s:ccol = stridx( s:line, a:char ) + 1
    if s:ccol > 0
      while s:ccol < a:col
        let s:line = substitute( s:line, a:char, s:repl_char, "" )
        let s:ccol = stridx( s:line, a:char ) + 1
      endwhile
      call setline( s:lineno, s:line )
    endif
    let s:lineno = s:lineno + 1
  endwhile
endfunction

"
" After selecting lines of text, hit the following:
"  SPACE c       line up column on colon   (Useful in Javascript and json)
"  SPACE e       line up column on =       (Useful in perl)
"  SPACE a       line up column on AS      (Useful in SQL select list)
"
vnoremap <silent> <Leader>c :call IndentColLines( ':' )<CR>
vnoremap <silent> <Leader>e :call IndentColLines( '=' )<CR>
vnoremap <silent> <Leader>a :call IndentColLines( 'AS' )<CR>

