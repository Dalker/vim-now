"""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Never Optimal Wiki - syntax highlighting and conceals "
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" two possible styles of comment (script style # and LaTeX style %)
syntax match Comment "#.*"
syntax match Comment "%.*"

" titles: = ... = (non equal signs between equal signs)
syntax match Title "=\+[^=]*=\+"

" emphasized text: * ... * (non asterisks between asterisks)
syntax match Special "\*[^\*]*\*"

" links: they're simply proper paths, that *must* start with a dir name
"" regexp 1: starts with ' ./' or ' /' or '  /'
" syntax match Keyword "[\. \t\~]/\f\+" 
syntax match Keyword "[\. \t\~]/[a-zA-Z/\_\-\.]\+" 
"" regexp 2: starts with '/' at start of line
" syntax match Keyword "^/\f\+"
syntax match Keyword "^/[a-zA-Z/\_\-\.]\+"
" note that acceptable characters are more restricted than with \f (e.g. comma is forbidden)

" conceals (visual replacement of text on non-cursor lines)
"" LaTeX-style greek letters
syn match normal '\\eps' conceal cchar=ε

"------------------------
" CopyLeft by dalker
" create date: 2015-07-12
" modif  date: 2015-11-01
