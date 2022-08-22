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
:set statusline=%F\ %m%=col:%c\ \ line:%l/%L\ \ --%p%%--\ %a\ 
:set laststatus=2
:set expandtab
:set shiftwidth=2
vnoremap > >gv
vnoremap < <gv

" doesn't seem to work
"augroup open_and_close
"  autocmd!
"  autocmd InsertLeave,WinEnter * set cursorline
"  autocmd InsertEnter,WInLeave * set nocursorline
"  highlight CursorLine cterm=bold ctermbg=0 ctermfg=14
"augroup END

" map the Space-Quote keystroke to surround the current word with quotes
augroup html_file
  autocmd!
  autocmd! BufRead,BufNewFile *.tmpl set filetype=html
  autocmd FileType html nnoremap <buffer> <Leader>" :execute "normal \<Plug>Ysurroundiw\""<CR>
augroup END


highlight Search ctermfg=black ctermbg=blue
:set hls
noremap <silent> <C-L> :nohlsearch<CR>     " Turn off the match highlighting until the next search

" Act naturally when lines wrap
" 2021-12-21 -jam- These act weird when nowrap is set, so... disabling for now
"nnoremap j  gj
"nnoremap k  gk
"nnoremap ^  g^
"nnoremap 0  g0
"nnoremap $  g$
"nnoremap gj j
"nnoremap gk k
"nnoremap g^ ^
"nnoremap g$ $
"nnoremap g0 0

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

  "
  " Loop through the lines in the range to find the max col
  "
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
"  SPACE c or :    line up column on colon   (Useful in Javascript and json)
"  SPACE e or =    line up column on =       (Useful in perl)
"  SPACE g or >    line up column on =>      (Useful in perl)
"  SPACE a         line up column on AS      (Useful in SQL select list)
"
vnoremap <silent> <Leader>c :call IndentColLines( ':' )<CR>
vnoremap <silent> <Leader>: :call IndentColLines( ':' )<CR>

vnoremap <silent> <Leader>e :call IndentColLines( '=' )<CR>
vnoremap <silent> <Leader>= :call IndentColLines( '=' )<CR>

vnoremap <silent> <Leader>g :call IndentColLines( '=>' )<CR>
vnoremap <silent> <Leader>> :call IndentColLines( '=>' )<CR>

vnoremap <silent> <Leader>a :call IndentColLines( 'AS' )<CR>

autocmd FileType perl setlocal commentstring=#\ %s
autocmd FileType bash setlocal commentstring=#\ %s
autocmd FileType html setlocal commentstring=//\ %s
autocmd FileType javascript setlocal commentstring=//\ %s
