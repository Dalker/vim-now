"""""""""""""""""""""""""""""""""""
" Never Optimal Wiki - vim plugin "
"""""""""""""""""""""""""""""""""""
"
" basic configuration
" Customization {{{
let s:nowrootdir  = '~/active/now/'          " base dir for NeverOptimaWiki (used for <l>ni)
let s:randomdir   = s:nowrootdir . 'in/'     " dir for random notes (used for <l>nr)
let s:classifydir = '../circulating/'        " default for classifying, relative to random notes (used for <ll>n)
let s:shadowdir   = s:nowrootdir . 'shadow/' " dir for keeping a date-sorted 'shadow' of content  (used for <ll>s)
let s:NOWsuffix   = '.now'                   " suffix for now files
let s:indexname   = 'index' . s:NOWsuffix    " name of index files (for <l>ni and for -)
let s:randombase  = 'random'                 " base name for random note files
let s:webbrowser  = '!firefox '              " choice of web browser
let s:mimeopencmd = '!mimeopen '             " choice of mimeopen program
" }}}
" define filetype for Never Optimal Wiki "{{{
execute 'silent! normal! :autocmd BufNewFile,BufRead *' . s:NOWsuffix . " set filetype=now" . "\r"
"}}}
" global mappings
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
" functions called from ftplugin
function! NOWsetsuffix() "{{{
" set gf suffix (called from ftplugin) 
  execute "silent! normal! :set suffixesadd=" . s:NOWsuffix . "\r"
endfunction
" }}}
function! NOWbufup() "{{{
" behaviour of - while on now files (mapped on ftplugin)
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
function! NOWshadow() "{{{
" copy current file to shadow dir (mapped on ftplugin)
  " shadowed contents have a date prefixed to the file name, to keep
  " a historical record of contents
  let l:destination = s:shadowdir . strftime('%Y.%m.%d') . '-' . expand('%:t')
  let l:actual_file = expand('%:p')
  execute 'normal! :saveas ' . l:destination . "\r"
  execute 'normal! :e '      . l:actual_file . "\r"
  execute 'normal! :bd '     . l:destination . "\r"
endfunction "}}}
function! NOWname() "{{{
" name and move elsewhere (mapped on ftplugin)
  let l:destination = input("enter NOW name (without suffix) or <esc> to abort\n> ", "" , 'file') . s:NOWsuffix
  if l:destination ==# "" || l:destination ==# s:NOWsuffix
    echo "\nNOW naming aborted by user"
  elseif filereadable(l:destination)
    echo "\nNOW naming aborted: file exists"
  else
    let l:prev_name = expand('%:t')
    execute 'normal! :saveas '     . l:destination . "\r" 
    execute 'normal! :!rm '        . l:prev_name   . "\r" 
    execute 'silent! normal! :bd ' . l:prev_name   . "\r" 
  endif
endfunction "}}}
function! NOWclassify() "{{{
" classify, i.e. move elsewhere (mapped on ftplugin)
  let l:dest_dir = input("enter destination or <esc> to abort\n> ", s:classifydir , 'file')
  let l:dest_file = fnamemodify(l:dest_dir, ":p") . expand('%:t')
  if l:dest_dir ==# ""
    echo "\nNOW classifying aborted by user"
  elseif isdirectory(l:dest_dir) == 0 " in vim false is set as 0
    echo "\nNOW classifying aborted: " . l:dest_dir . " is not a directory"
  elseif filereadable(l:dest_file)
    echo "\nNOW classifying aborted: file exists"
  else
    let l:prev_dir  = expand('%:p:h')
    let l:prev_file = expand('%:p')
    execute 'normal! :saveas '          . l:dest_file . "\r"
    execute 'normal! :!rm '             . l:prev_file   . "\r"
    execute 'silent! normal! :Explore ' . l:prev_dir    . "\r"
  endif
endfunction "}}}
function! NOWCreateUnderCursor() "{{{
" create file or dir under cursor (mapped on ftplugin)
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
function! NOWMimeOpenUnderCursor() "{{{
" open under cursor with browser or mimeopen (mapped on ftplugin)
  execute "normal! \"zyiW"
  " following need is not really needed if autochdir is on, but it's a good precaution just in case
  execute "normal! :cd %:p:h\r"
  if @z =~# "^http://" ||  @z =~# "^https://" ||  @z =~# "^www."
    "this is assumed to be an url
    execute "normal! :" . s:webbrowser . @z . "\r"
  else
    " use generic external open command
    execute "normal! :" . s:mimeopencmd . @z . "\r"
  endif
endfun "}}}
"
"------------------------
" CopyLeft by dalker
" create date: 2015-08-18
" modif  date: 2015-11-05
