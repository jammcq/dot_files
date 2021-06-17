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

