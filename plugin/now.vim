"""""""""""""""""""""""""""""""""""""""""""""
" Never Optimal Wiki - plugin configuration "
"""""""""""""""""""""""""""""""""""""""""""""

" Option setting function defined
function! <SID>SetOption(name, map) "{{{
  if !exists("g:NOW_" . a:name)
    execute "silent! normal! :let g:NOW_" . a:name . " = '" . a:map . "'\r"
  endif
endfunction "}}}
" For each option, default value is set unless previously overridden in user's .vimrc
" directories {{{
call <SID>SetOption("rootdir",     $HOME . "/now/")
call <SID>SetOption("randomdir",   g:NOW_rootdir . '/in/')    
call <SID>SetOption("shadowdir",   g:NOW_rootdir . '/shadow/')
call <SID>SetOption("classifydir", g:NOW_rootdir . '/circulating/')      
"}}}
" file names and suffixes "{{{
call <SID>SetOption("suffix",       '.now')
call <SID>SetOption("indexname",    'index')
call <SID>SetOption("randombase",   'random')
" g:NOW_mimesuffixes gets exceptional treatment as it is the only list option
if !exists("g:NOW_mimesuffixes")
  let g:NOW_mimesuffixes = [".pdf", ".png", ".jpg"]
endif
"}}}
" external programs "{{{
call <SID>SetOption("webbrowser", '!firefox ')
call <SID>SetOption("mimeopencmd",'!mimeopen ')
"}}}
" global key mappings "{{{
call <SID>SetOption("map_goroot",  "<leader>nn") " go to NOW index
call <SID>SetOption("map_rnote",   "<leader>nr") " edit new random note
call <SID>SetOption("map_mkindex", "<leader>ni") " create/update and goto index at cwd
call <SID>SetOption("map_help",    "<leader>nh") " show NOW help
"}}}

" Once options are set, plugin is initialized
" Associate Never Optimal Wiki filetype to configured suffix " {{{
execute 'silent! normal! :autocmd BufNewFile,BufRead *' . g:NOW_suffix . " set filetype=now" . "\r"
" }}}
" Setup global mappings - usable from anywhere on vim{{{
" - access NOW index from anywhere on vim
execute "silent! normal! :nnoremap " . g:NOW_map_goroot . " :call now#Index()<cr>". "\r" 
" - create a new file labeled randomNN for next available natural NN and edit it
execute "silent! normal! :nnoremap " . g:NOW_map_rnote . " :call now#RandomNote()<cr>". "\r" 
" - create or update local directory's now index
execute "silent! normal! :nnoremap " . g:NOW_map_mkindex . " :call now#MakeIndex()<cr>". "\r" 
" - show NOW help from anywhere
execute "silent! normal! :nnoremap " . g:NOW_map_help . " :help now<cr>". "\r" 
"}}}

"------------------------
" CopyLeft by dalker
" create date: 2015-08-18
" modif  date: 2016-11-06
