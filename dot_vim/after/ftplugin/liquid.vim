" Set native comment markers in Liquid files so using vim-commentary doesn't 
" use the ugly Liquid comment syntax instead of the HTML/XML syntax
" Stolen from https://ryanlue.com/posts/2016-11-03-vim-plugins-for-jekyll
let liquid_ext = expand('%:e:e')
if liquid_ext =~ '\(ht\|x\)ml'
  set commentstring=<!--%s-->
elseif liquid_ext =~ 'css'
  set commentstring=/*%s*/
endif

