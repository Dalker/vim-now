"""""""""""""""""""""""""""""""""""
" Never Optimal Wiki - vim plugin "
"""""""""""""""""""""""""""""""""""
"
" basic configuration
" Customization {{{
let g:NOW_rootdir     = '~/active/now/'       " base dir for NeverOptimaWiki (used for <l>ni)
let g:NOW_randomdir   = g:NOW_rootdir . 'in/' " dir for random notes (used for <l>nr)
let g:NOW_classifydir = '../circulating/'     " default for classifying, relative to random notes (used for <ll>n)
let g:NOW_shadowdir   = g:NOW_rootdir . 'shadow/' " dir for keeping a date-sorted 'shadow' of content  (used for <ll>s)
let g:NOW_suffix      = '.now'                    " suffix for now files
let g:NOW_indexname   = 'index' . g:NOW_suffix    " name of index files (for <l>ni and for -)
let g:NOW_randombase  = 'random'      " base name for random note files
let g:NOW_webbrowser  = '!firefox '   " choice of web browser
let g:NOW_mimeopencmd = '!mimeopen '  " choice of mimeopen program
" }}}
" define filetype for Never Optimal Wiki "{{{
execute 'silent! normal! :autocmd BufNewFile,BufRead *' . g:NOW_suffix . " set filetype=now" . "\r"
"}}}
" global mappings
" <l>ni to access NOW from anywhere on vim "{{{
execute "silent! normal! :nnoremap <leader>ni :e" g:NOW_rootdir . g:NOW_indexname . "<cr>" . "\r"
"}}}
" <l>nr to edit next random note from anywhere on vim {{{
nnoremap <leader>nr :call now#RandomNote()<cr> 
"}}}
"
"------------------------
" CopyLeft by dalker
" create date: 2015-08-18
" modif  date: 2015-11-07
