"""""""""""""""""""""""""""""""""""
" Never Optimal Wiki - vim plugin "
"""""""""""""""""""""""""""""""""""

" Customization {{{
let s:nowrootdir = '~/active/now/'            " base dir for NeverOptimaWiki (used for <l>ni)
let s:randomdir  = s:nowrootdir . 'in/'       " dir for random notes (used for <l>nr)
let s:shadowdir  = s:nowrootdir . 'shadow/'   " dir for keeping a date-sorted 'shadow' of content  (used for <ll>s)
let s:NOWsuffix     = '.now'                     " suffix for now files
let s:indexname  = 'index' . s:NOWsuffix         " name of index files (for <l>ni and for -)
let s:randombase = 'random'                   " base name for random note files
" }}}

" O.S. specific (POSIX compliant by default) {{{
" note: this plugin currently uses the following *nix commands:
"                   'cp -i' and 'mv -i'
" as they perform nice checks before copying/moving a file
" so if you want to use this plugin in a different O.S., you'll
" have to replace them by something equivalent
let s:cpcommand  = '!cp -i '
let s:mvcommand  = '!mv -i '
" }}}

" define filetype for Never Optimal Wiki "{{{
execute 'silent! normal! :autocmd BufNewFile,BufRead *' . s:NOWsuffix . " set filetype=now" . "\r"
"}}}

" <l>ni to access NOW from anywhere on vim "{{{
execute "silent! normal! :nnoremap <leader>ni :e" s:nowrootdir . s:indexname . "<cr>" . "\r"
"}}}
" <l>nr to edit next random note from anywhere on vim {{{
function! NOWrandom()
  " random notes get into the following dir
  execute "normal! :cd " . s:randomdir  . "\r"
  " what follows looks for the next available number and uses it
  " to create a randomXX file
  let s:nextnow = 1
  let s:number  = 0
  while s:nextnow > 0
    let s:number = s:number + 1
    if s:number < 10
      let s:currentfile = s:randombase . '0' . s:number . s:NOWsuffix
    else
      let s:currentfile = s:randombase . s:number . s:NOWsuffix
    endif
    if ! filereadable(s:currentfile) 
      let s:nextnow = s:currentfile
    endif
  endwhile
  execute "normal! :e " . s:nextnow . "\r"
endfun
nnoremap <leader>nr :call NOWrandom()<cr> 
"}}}

" set gf suffix (called from ftplugin) {{{
function! NOWsetsuffix()
  execute "silent! normal! :set suffixesadd=" . s:NOWsuffix . "\r"
endfunction
" }}}

" behaviour of - while on now files (mapped on ftplugin) {{{
function! NOWbufup()
  if expand('%:t') ==# s:indexname
    " if on index file, leave it for netrw
    open ./
  else
    " if there's an index file, update and enter it
    if filereadable(s:indexname)
"       execute "normal! :!nowindex\r"
      execute "normal! :open " . s:indexname . "\r"
    else
      " otherwise goto netrw
      open ./
    endif
  end
endfunction "}}}

" copy current file to shadow dir (mapped on ftplugin) {{{
function! NOWshadow()
  " shadowed contents have a date prefixed to the file name, to keep
  " a historical record of contents
  let l:destination = s:shadowdir . strftime('%Y.%m.%d') . '-' . expand('%:t')
  execute 'normal! :' s:cpcommand . expand('%:t') . ' ' . l:destination . "\r"
endfunction "}}}

" name and move elsewhere (mapped on ftplugin) {{{
function! NOWname()
  let l:destination = input("enter NOW name (without suffix) or <cr> to abort\n> ", '../', 'file')
  if l:destination ==# "../"
    echo "\naborting NOW naming"
  else
    execute 'normal! :' . s:mvcommand . expand('%:t') . ' ' . l:destination . s:NOWsuffix . "\r" 
    bd
    execute "normal! :open " . l:destination . s:NOWsuffix . "\r"
  endif
endfunction "}}}

" create file or dir under cursor (mapped on ftplugin) {{{
function! NOWCreateUnderCursor()
  " capture name of dir/file to be created on @z
  execute "normal! \"zyiW"
  " following is not really needed if autochdir is on, but it's a good precaution just in case
  execute "normal! :cd %:p:h\r"
  if filereadable(@z)
    " file/dir already exists - just open it
    execute "normal! :open " . @z
  else
    " it doesn't exist - figure out if it's intended as a dir
    if @z =~ '/$' 
      " it's meant to be a dir
      call mkdir(@z, 'p')
      let l:tobeopened = @z
    else
      " it's meant to be a file
      if @z =~ '.\..*$'
        " suffix already present
        let l:tobeopened = @z
      else
        let l:tobeopened = @z . s:NOWsuffix
      endif
    endif
    !echo "about to edit " . l:tobeopened . "\r"
    execute "normal! :edit " . l:tobeopened . "\r"
  endif
endfun "}}}

"------------------------
" CopyLeft by dalker
" create date: 2015-08-18
" modif  date: 2015-10-31
