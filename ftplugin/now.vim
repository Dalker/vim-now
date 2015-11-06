""""""""""""""""""""""""""""""""""""""""
" Never Optimal Wiki - filetype plugin "
""""""""""""""""""""""""""""""""""""""""

" Optional configuration {{{
" when entering a buffer, cd to its dir:
" cd %:p:h 
" uncomment the previous line if autochdir is not already set elsewhere in vimrc or .vim

" navigation between pages is expected to be done the vim way, with 'gf' and 'ctrl-o'
" optionally uncomment next line to also allow navigation with 'enter', to be consistent with netrw
nnoremap <buffer> <cr> gf
" WARNING: the previous line overrides the standard map (where <return> is like + in normal mode)
" }}}

" gf accepts NOW suffix as an auto-suffix {{{
call now#SetSuffix()
"}}}
" <ll>gf mimeopens file under cursor {{{
nnoremap <buffer> <localleader>gf :call now#MimeOpenUnderCursor()<cr>
"}}}
" <ll>cf creates file or dir under cursor, possibly adding suffix {{{
nnoremap <buffer> <localleader>cf :call now#CreateUnderCursor()<cr>gf
"}}}
" - goes up to either index or netrw using {{{
nmap <buffer> - :call now#BufUp()<cr>
"}}}
" <ll>s copies current file to shadow with date preprended {{{
nmap <buffer> <LocalLeader>s :call now#Shadow()<cr>
"}}}
" <ll>n interactively names file to something else {{{
nmap <buffer> <localleader>n :call now#Name()<cr>
"}}}
" <ll>c interactively classifies (moves) a  file somewhere else {{{
nmap <buffer> <localleader>c :call now#Classify()<cr>
"}}}

" allow some concealing "{{{
setlocal conceallevel=2
" see ../after/syntax/now.vim
"}}}
" folding based on sections started with =...= title "{{{
setlocal foldmethod=syntax
syn region myFold start="^=" end="^\n" transparent fold
syn sync fromstart
"}}}

"------------------------
" CopyLeft by dalker
" create date: 2015-07-10
" modif  date: 2015-11-07
