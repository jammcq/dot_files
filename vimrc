:let loaded_matchparen = 1
:set scrolloff=2
:set nowrapscan
:set nowrap
:set background=dark
:hi special ctermfg=magenta
:set modeline
:set statusline=%f
:set laststatus=2
silent!  set belloff=all

"highlight ExtraWhitespace ctermbg=red guibg=red
"match ExtraWhitespace /\s\+$/
"autocmd BufWinEnter * match ExtraWhitespace /\s\+$/
"autocmd InsertEnter * match ExtraWhitespace /\s\+\%#\@<!$/
"autocmd InsertLeave * match ExtraWhitespace /\s\+$/
"autocmd BufWinLeave * call clearmatches()
