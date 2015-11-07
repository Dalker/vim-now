"""""""""""""""""""""""""""""""""""""""""""""
" Never Optimal Wiki - plugin configuration "
"""""""""""""""""""""""""""""""""""""""""""""
"
" To override a default value for an option, copy and uncomment one of the following on .vimrc
" Most users will only need to override g:NOW_rootdir and possibly optional external programs    
"
" directories
"   let g:NOW_rootdir     = '~/active/now/'   " base dir for NeverOptimaWiki                      (used for <l>ni)
"   let g:NOW_randomdir   = 'in/'             " subdir for random notes, relative to NOW root dir (used for <l>nr)
"   let g:NOW_shadowdir   = 'shadow/'         " subdir for date-sorted 'shadow' content           (used for <ll>s) 
"   let g:NOW_classifydir = '../circulating/' " default for classifying, relative to random notes (used for <ll>c)
" file names
"   let g:NOW_suffix      = '.now'            " suffix for now files
"   let g:NOW_indexname   = 'index'           " name of index files, without suffix               (used for <l>ni & -)
"   let g:NOW_randombase  = 'random'          " base name for random note files                   (used for <l>nr)
" external programs 
"   let g:NOW_webbrowser  = '!firefox '       " choice of web browser                             (used for <ll>gf)
"   let g:NOW_mimeopencmd = '!mimeopen '      " choice of mimeopen program                        (used for <ll>gf)
" global key mappings
"   let g:NOW_map_index   = '<leader>ni'      " go to NOW index  
"   let g:NOW_map_index   = '<leader>nr'      " create new random note
"   let g:NOW_map_mkindex = '<leader>nk'      " create/update local index
"
" For each option, default value is set unless user previously overridden by .vimrc
function! <SID>SetOption(name, map) "{{{
  if !exists("g:NOW_" . a:name)
    execute "silent! normal! :let g:NOW_" . a:name . " = '" . a:map . "'\r"
  endif
endfunction "}}}
" directories {{{
call <SID>SetOption("rootdir",     '~/active/now/')
call <SID>SetOption("randomdir",   'in/')    
call <SID>SetOption("shadowdir",   'shadow/')
call <SID>SetOption("classifydir", '../circulating/')      
"}}}
" file names "{{{
call <SID>SetOption("suffix",     '.now')
call <SID>SetOption("indexname",  'index')
call <SID>SetOption("randombase", 'random')
"}}}
" external programs "{{{
call <SID>SetOption("webbrowser", '!firefox ')
call <SID>SetOption("mimeopencmd",'!mimeopen ')
"}}}
" global key mappings "{{{
call <SID>SetOption("map_index",   "<leader>ni") " go to NOW index
call <SID>SetOption("map_rnote",   "<leader>nr") " edit new random note
call <SID>SetOption("map_mkindex", "<leader>nk") " make index at cwd
"}}}

" Once options are set, plugin is initialized
" Associate Never Optimal Wiki filetype to configured suffix " {{{
execute 'silent! normal! :autocmd BufNewFile,BufRead *' . g:NOW_suffix . " set filetype=now" . "\r"
" specific setup and mappings within NOW filetype defined on ../ftplugin/now.vim
" syntax highlighting for NOW filetype defined on ../after/syntax/now.vim
" }}}
" Setup global mappings - usable from anywhere on vim{{{
" - access NOW index from anywhere on vim
" execute "silent! normal! :nnoremap " . g:NOW_map_index . " :e" g:NOW_rootdir . g:NOW_indexname . "<cr>" . "\r"
execute "silent! normal! :nnoremap " . g:NOW_map_index . " :call now#Index()<cr>". "\r" 
" - create a new file labeled randomNN for next available natural NN and edit it
execute "silent! normal! :nnoremap " . g:NOW_map_rnote . " :call now#RandomNote()<cr>". "\r" 
execute "silent! normal! :nnoremap " . g:NOW_map_mkindex . " :call now#MakeIndex()<cr>". "\r" 
"}}}
"
"------------------------
" CopyLeft by dalker
" create date: 2015-08-18
" modif  date: 2015-11-07
