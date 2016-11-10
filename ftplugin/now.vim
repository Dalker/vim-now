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
function! <SID>SetOption(name, map) "{{{
  if !exists("g:NOW_" . a:name)
    execute "silent! normal! :let g:NOW_" . a:name . " = '" . a:map . "'\r"
  endif
endfunction "}}}
" interactively (re)name file (default: <ll>n) {{{
call <SID>SetOption("map_name", "<localleader>n") " (re)name file
execute "silent! normal! :nnoremap " . g:NOW_map_name . " :call now#Name()<cr>". "\r" 
"}}}
" interactively classify file, i.e. move to other dir, keeping name (default {{{
"                         key: <ll>c, default destination: g:NOW_classifydir)
call <SID>SetOption("map_classify", "<localleader>c") " classify file
execute "silent! normal! :nnoremap " . g:NOW_map_classify . " :call now#Classify()<cr>". "\r" 
"}}}
" make a 'shadow' copy of file, preprending date (default key: <ll>a, {{{
"                                                 destination: g:NOW_shadowdir)
call <SID>SetOption("map_shadow", "<localleader>s") " make a shadow copy of file
execute "silent! normal! :nnoremap " . g:NOW_map_shadow . " :call now#Shadow()<cr>". "\r" 
"}}}

" Mappings to increase/decrease the 'title' level of current line
nnoremap <localleader>t I= <esc>A =<esc>0
" TODO: detect if already titled, in which case add = but no space
nnoremap <localleader>T :s/^= //e<cr>:s/ =$//e<cr>:let @/=""<cr>
" TODO: detect if subtitle, in which case remove = but no space

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
" modif  date: 2016-11-10
