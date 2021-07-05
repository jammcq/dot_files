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

"
" Functions to clean up JSON structures by aligning the colon character
" on each line into a column.
"
function! IndentColAuto() range
  let s:mcol   = 1
  let s:lineno = a:firstline
  while s:lineno <= a:lastline           " Loop through the lines in the range to find the max col
    let s:line = getline( s:lineno )
    let s:cidx = stridx( s:line, ':' )   " Find the index of the first ':' on the line
    let s:col  = s:cidx + 1              " Need to add 1 because index is 0-based
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
  execute a:firstline . "," . a:lastline . 'call IndentCol( s:mcol )'
endfunction

function! IndentCol( col ) range
  let s:lineno = a:firstline
  while s:lineno <= a:lastline
    let s:line = getline(s:lineno)
    let s:ccol = stridx( s:line, ":") + 1
    if s:ccol > 0
      while s:ccol < a:col
        let s:line = substitute( s:line, ":", " :", "" )
        let s:ccol = stridx( s:line, ':' ) + 1
      endwhile
      call setline( s:lineno, s:line )
    endif
    let s:lineno = s:lineno + 1
  endwhile
endfunction

"
" Finally, map the <Space>c to call IndentColAuto on the visual range
"
vnoremap <silent> <Leader>c :call IndentColAuto()<CR>
