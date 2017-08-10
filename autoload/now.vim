""""""""""""""""""""""""""""""""""""""""""""
" Never Optimal Wiki - function definition "
""""""""""""""""""""""""""""""""""""""""""""
"  these definitions are loaded on first   "
"  opening a NOW file during vim session   "
""""""""""""""""""""""""""""""""""""""""""""
"
" functions called from ../plugin/now.vim   (global mappings)
function! now#Index() " {{{
  if !isdirectory(g:NOW_rootdir)
    call mkdir(g:NOW_rootdir,"p")
  endif
  execute "normal! :edit " . g:NOW_rootdir . '/' . g:NOW_indexname . g:NOW_suffix . "\r"
endfun
"}}}
function! now#RandomNote() " {{{
  " create random note dir if necessary, then enter it
  " note: '~' doesn't work for home dir in vim, so substitute with full path if needed
  let l:rndir = substitute(g:NOW_randomdir , "\\~", $HOME, "")
  if !isdirectory(l:rndir)
    call mkdir(l:rndir,"p")
  endif
  execute "normal! :cd " . l:rndir . "\r"
  " look for the next available random note number
  let l:number = 0
  while l:number >= 0
    let l:number = l:number + 1
    if l:number < 10
      let l:currentfile = g:NOW_randombase . '0' . l:number . g:NOW_suffix
    else
      let l:currentfile = g:NOW_randombase . l:number . g:NOW_suffix
    endif
    if ! filereadable(l:currentfile) " found available file name
      let l:number = -1              " => exit loop
    endif
  endwhile
  execute "normal! :edit " . l:currentfile . "\r"
endfun
"}}}
function! now#MakeIndex() " {{{
  " NB: may have arrived here from now#BufUp or direct keymap
  " create or edit local index file
  execute "normal! :edit " . g:NOW_indexname . g:NOW_suffix . "\r"
  " then look at every file/dir from this location
  for l:file in split(glob('*'), '\n')
    " is it already on the file? (possibly suffix-less)
    let l:pattern = "./" . substitute(l:file, g:NOW_suffix, '', '')
    " funny regexp aims to distinguish e.g. bla from bla.pdf
    if l:file !=# g:NOW_indexname . g:NOW_suffix && !search(l:pattern . '\($\|[^\.]\)', 'nw')
      " it's not -> append it to last line
      execute "normal! :$append" . "\r" . l:pattern . "\r"
    endif
  endfor
endfun
"}}}
" functions called from ../ftplugin/now.vim (buffer specific)
function! now#SetSuffix() "{{{
  " set gf suffix (called from ftplugin) 
  execute "silent! normal! :set suffixesadd=" . g:NOW_suffix . "\r"
endfunction
" }}}
function! now#BufEnter() "{{{
" behaviour of <enter> while on now files (mapped on ftplugin)
  " determine potential destination and its suffix, if present
  let l:dest = expand("<cfile>")
  let l:destsuffix = strpart(l:dest, match(l:dest, '\.[a-zA-Z]\+$'))
  " then decide what to do
  if isdirectory(l:dest)
    " if pointing to a directory, update and enter index file there
    execute 'normal! :cd ' . l:dest . "\r"
    if filereadable(g:NOW_indexname . g:NOW_suffix)
      " if there's an index file, update and enter it
      call now#MakeIndex()
    else
      " otherwise goto netrw
      edit ./
    endif
  elseif l:dest =~# "^http://" ||  l:dest =~# "^https://" ||  l:dest =~# "^www."
    " f destination assumed to be an url, invoke web browser
    execute "normal! :" . g:NOW_webbrowser . " " . l:dest . "\r"
  elseif filereadable(l:dest) && count(g:NOW_mimesuffixes, l:destsuffix) > 0
    " f destination assumed to be externally openable, invoke mime opener
    execute "normal! :" . g:NOW_mimeopencmd. " " . l:dest . "\r"
  else
    " otherwise edit the file, whether it exists or not
    " N.B: this is a bit tricky, because <cfile> does not detect an optional
    " suffix, as discussed in the following Q/A topic:
    " https://vi.stackexchange.com/q/9627/2058
    try
      " if a file can be found, with optional suffix, open it
      normal gf
    catch
      " otherwise, create the file pointed to
      execute 'normal! :e ' . l:dest . g:NOW_suffix . "\r"
    endtry
  endif
endfunction "}}}
function! now#BufUp() "{{{
" behaviour of - while on now files (mapped on ftplugin)
  if expand('%:t') ==# g:NOW_indexname . g:NOW_suffix
    " if on index file, check if parent dir has an index file
    if filereadable('../' . g:NOW_indexname . g:NOW_suffix)
      " if there's a parent index file, update and enter it
      cd ../
      call now#MakeIndex()
    else
      " otherwise goto netrw staying in same dir
      edit ./
    end
  elseif filereadable(g:NOW_indexname . g:NOW_suffix)
    " if there's an index file, update and enter it
    call now#MakeIndex()
  else
    " otherwise goto netrw
    edit ./
  endif
endfunction "}}}
function! now#Shadow() "{{{
" copy current file to shadow dir (mapped on ftplugin)
  " shadowed contents have a date prefixed to the file name, to keep
  " a historical record of contents
  let l:shadir = substitute(g:NOW_shadowdir , "\\~", $HOME, "")
  if !isdirectory(l:shadir)
    call mkdir(l:shadir,"p")
  endif
  let l:destination = strftime('%Y.%m.%d') . '-' . expand('%:t')
  let l:actual_file = expand('%:p')
  execute 'normal! :saveas ' . l:shadir . '/' . l:destination . "\r"
  execute 'normal! :e '      . l:actual_file . "\r"
  execute 'normal! :bd '     . l:destination . "\r"
  execute 'normal! :echo "made a shadow copy of file"' . "\r"
endfunction "}}}
function! now#Name() "{{{
" name in place (mapped on ftplugin)
  let l:answer = input("enter NOW name (without suffix) or <esc> to abort : ", "" , 'file') 
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
  let l:rndir = substitute(g:NOW_randomdir , "\\~", $HOME, "")
  let l:ldir = expand('%:p:h') . '/'
  if l:rndir ==# l:ldir
    let l:answer = input("enter destination dir or <esc> to abort : ", g:NOW_classifydir , 'file')
  else
    let l:answer = input("enter destination dir or <esc> to abort : ", l:ldir , 'file')
  end
  " verify if no dir (abort), if dir exists, or if needs creation
  let l:dest_dir  = fnamemodify(l:answer, ":p")
  if l:answer ==# ""
    echo "\nNOW classifying aborted by user"
    return
  elseif isdirectory(l:dest_dir) == 0 " in vim false is set as 0
    let l:create_dir = input("directory " . l:dest_dir . "does not exist. Create? (yes/*) : ", "" )
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
    execute "normal! :" . g:NOW_webbrowser . " " . @z . "\r"
  else
    " use generic external open command
    execute "normal! :" . g:NOW_mimeopencmd. " " . @z . "\r"
  endif
endfun "}}}
function! now#IncreaseTitleLevel() "{{{
  " check if there's already some titling
  if search('^=', 'c', line("."))
    " increase title level
    execute "normal! I=\eA=\e0"
  else
    " introduce level 1 title
    execute "normal! I= \eA =\e0"
  endif
endfun "}}}
function! now#DecreaseTitleLevel() "{{{
  " check if there's already some titling
  if search('^=', 'c', line("."))
    " remove title or decrease title level
    execute "normal! :s/^= //e\r:s/ =$//e\r"
    execute "normal! :s/^==/=/e\r:s/==$/=/e\r"
  endif
endfun "}}}
" function called when folding
function! now#SetFoldLevel(lnum) "{{{
  if getline(a:lnum) =~? '\v^\=\=\=\='
    " 'subsubtitle' line - start level 3 fold
    return '>4'
  elseif getline(a:lnum) =~? '\v^\=\=\='
    " 'subsubtitle' line - start level 3 fold
    return '>3'
  elseif getline(a:lnum) =~? '\v^\=\='
    " 'subtitle' line - start level 2 fold
    return '>2'
  elseif getline(a:lnum) =~? '\v^\='
    " 'title' line - start level 1 fold
    return '>1'
  else
    " normal line - keep foldlevel
    return '='
  endif
endfun "}}}
"
"------------------------
" CopyLeft by dalker
" create date: 2015-08-18
" modif  date: 2017-08-10
