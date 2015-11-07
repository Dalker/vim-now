""""""""""""""""""""""""""""""""""""""""""""
" Never Optimal Wiki - function definition "
""""""""""""""""""""""""""""""""""""""""""""
"  these definitions are loaded on first   "
"  opening a NOW file during vim session   "
""""""""""""""""""""""""""""""""""""""""""""
"
" function called from global mapping
function! now#RandomNote() " {{{
  " random notes get into the following dir
  execute "normal! :cd " . g:NOW_randomdir  . "\r"
  " what follows looks for the next available number and uses it
  " to create a randomXX file
  let l:nextnow = 1
  let l:number  = 0
  while l:nextnow > 0
    let l:number = l:number + 1
    if l:number < 10
      let l:currentfile = g:NOW_randombase . '0' . l:number . g:NOW_suffix
    else
      let l:currentfile = g:NOW_randombase . l:number . g:NOW_suffix
    endif
    if ! filereadable(l:currentfile) 
      let l:nextnow = l:currentfile
    endif
  endwhile
  execute "normal! :e " . l:nextnow . "\r"
endfun
"}}}
" functions called from ftplugin
function! now#SetSuffix() "{{{
  " set gf suffix (called from ftplugin) 
  execute "silent! normal! :set suffixesadd=" . g:NOW_suffix . "\r"
endfunction
" }}}
function! now#BufUp() "{{{
" behaviour of - while on now files (mapped on ftplugin)
  if expand('%:t') ==# g:NOW_indexname
    " if on index file, leave it for netrw
    open ./
  else
    " if there's an index file, update and enter it
    if filereadable(g:NOW_indexname)
"       execute "normal! :!nowindex\r"
      execute "normal! :open " . g:NOW_indexname . "\r"
    else
      " otherwise goto netrw
      open ./
    endif
  end
endfunction "}}}
function! now#Shadow() "{{{
" copy current file to shadow dir (mapped on ftplugin)
  " shadowed contents have a date prefixed to the file name, to keep
  " a historical record of contents
  let l:destination = g:NOW_shadowdir . strftime('%Y.%m.%d') . '-' . expand('%:t')
  let l:actual_file = expand('%:p')
  execute 'normal! :saveas ' . l:destination . "\r"
  execute 'normal! :e '      . l:actual_file . "\r"
  execute 'normal! :bd '     . l:destination . "\r"
endfunction "}}}
function! now#Name() "{{{
" name in place (mapped on ftplugin)
  let l:answer = input("enter NOW name (without suffix) or <esc> to abort\n> ", "" , 'file') 
  " following should ensure that this renames file *in place*
  let l:destination = fnamemodify(l:answer . g:NOW_suffix, ":t")
  if l:answer ==# ""
    echo "\nNOW: naming aborted by user"
  elseif filereadable(l:destination)
    echo "\nNOW: naming aborted: file exists"
  else
    let l:prev_name = expand('%:t')
    if rename (l:prev_name, l:destination) " true if failed (vim...)
      echo "\nNOW: naming had a problem"
    else
      execute 'silent! normal! :edit ' . l:destination . "\r"
      execute 'silent! normal! :bd '   . l:prev_name   . "\r" 
    end
  endif
endfunction "}}}
function! now#Classify() "{{{
" classify, i.e. move elsewhere, with same name (mapped on ftplugin)
  let l:answer = input("enter destination dir or <esc> to abort\n> ", g:NOW_classifydir , 'file')
  " verify if no dir (abort), if dir exists, or if needs creation
  let l:dest_dir  = fnamemodify(l:answer, ":p")
  if l:answer ==# ""
    echo "\nNOW classifying aborted by user"
    return
  elseif isdirectory(l:dest_dir) == 0 " in vim false is set as 0
    let l:create_dir = input("directory " . l:dest_dir . "does not exist. Create? (yes/*) > ", "" )
    if l:create_dir ==# "yes"
      call mkdir (l:dest_dir, "p")
    else
      echo "\nNOW classifying aborted: directory not created"
      return
    end
  end
  " re-check everything, then move file
  " 'fnamemodify' again to make sure slashes are correct after creation
  let l:dest_dir  = fnamemodify(l:answer, ":p")
  let l:dest_file = l:dest_dir . expand('%:t')
  if isdirectory(l:dest_dir) == 0 " in vim false is set as 0
    echo "\nNOW classifying aborted: directory does not exist"
  elseif filereadable(l:dest_file)
    echo "\nNOW classifying aborted: file exists"
  else
    let l:prev_dir  = expand('%:p:h')
    let l:prev_file = expand('%:p')
"     execute 'normal! :saveas '          . l:dest_file . "\r"
"     execute 'normal! :!rm '             . l:prev_file   . "\r"
    if rename (l:prev_file, l:dest_file) " true if failed (vim...)
      echo "\nNOW: classify had a problem"
    else
      execute 'silent! normal! :Explore ' . l:prev_dir    . "\r"
    end
  endif
endfunction "}}}
function! now#CreateUnderCursor() "{{{
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
        let l:tobeopened = @z . g:NOW_suffix
      endif
    endif
    !echo "about to edit " . l:tobeopened . "\r"
    execute "normal! :edit " . l:tobeopened . "\r"
  endif
endfun "}}}
function! now#MimeOpenUnderCursor() "{{{
" open under cursor with browser or mimeopen (mapped on ftplugin)
  execute "normal! \"zyiW"
  " following need is not really needed if autochdir is on, but it's a good precaution just in case
  execute "normal! :cd %:p:h\r"
  if @z =~# "^http://" ||  @z =~# "^https://" ||  @z =~# "^www."
    "this is assumed to be an url
    execute "normal! :" . g:NOW_webbrowser . @z . "\r"
  else
    " use generic external open command
    execute "normal! :" . g:NOW_mimeopencmd . @z . "\r"
  endif
endfun "}}}
"
"------------------------
" CopyLeft by dalker
" create date: 2015-08-18
" modif  date: 2015-11-07
