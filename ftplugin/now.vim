""""""""""""""""""""""""""""""""""""""""
" Never Optimal Wiki - filetype plugin "
""""""""""""""""""""""""""""""""""""""""
" navigation between pages is expected to be done the vim way, with 'gf' and 'ctrl-o'

" Some adjustement of vim behaviour when in a NOW buffer
" when entering a buffer, cd to its dir {{{
"  (unless already done by global option)
if &autochdir != 1
  cd %:p:h 
endif
"}}}
" allow navigation with 'enter', to be consistent with netrw {{{
" nnoremap <buffer> <cr> gf
nnoremap <buffer> <cr> :call now#BufEnter()<cr>
" WARNING: the previous line overrides the standard map (where <return> is like + in normal mode)
" }}}

" Extra file navigation mappings
" - goes up to index (if it exists) or netrw {{{
nmap <buffer> - :call now#BufUp()<cr>
"}}}
" gf accepts NOW suffix as an auto-suffix {{{
call now#SetSuffix()
"}}}
" <ll>gf mimeopens file under cursor {{{
nnoremap <buffer> <localleader>gf :call now#MimeOpenUnderCursor()<cr>
"}}}
" <ll>cf creates file or dir under cursor, possibly adding suffix {{{
nnoremap <buffer> <localleader>cf :call now#CreateUnderCursor()<cr>gf
"}}}

" Mappings to move files around
" <ll>n interactively names file to something else {{{
nmap <buffer> <localleader>n :call now#Name()<cr>
"}}}
" <ll>m interactively moves a file somewhere else {{{
nmap <buffer> <localleader>m :call now#Classify()<cr>
"}}}
" <ll>a archives current file in shadow dir, with date preprended {{{
nmap <buffer> <LocalLeader>a :call now#Shadow()<cr>
"}}}

" Other properties of NOW buffers
" allow some concealing "{{{
setlocal conceallevel=2
" see ../after/syntax/now.vim
"}}}
" folding based on sections started with =...= title "{{{
setlocal foldmethod=expr
setlocal foldexpr=now#SetFoldLevel(v:lnum)
setlocal foldlevel=1
"}}}

"------------------------
" CopyLeft by dalker
" create date: 2015-07-10
" modif  date: 2016-10-08
