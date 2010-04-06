exec 'so '.expand('<sfile>:h').'/../xmlparse.vim'
scriptencoding utf-8

function! s:dump(node, syntax)
  let syntax = a:syntax
  if type(a:node) == 1
    if len(syntax) | exe "echohl ".syntax | endif
    echon a:node
    echohl None
  elseif type(a:node) == 3
    for n in a:node
      call s:dump(n, syntax)
    endfor
    return
  elseif type(a:node) == 4
      "echo a:node.name
      "echo a:node.attr
    let syndef = {'kt' : 'Type', 'mi' : 'Number', 'nb' : 'Statement', 'kp' : 'Statement', 'nn' : 'Define', 'nc' : 'Constant', 'no' : 'Constant', 'k'  : 'Include', 's'  : 'String', 's1' : 'String', 'err': 'Error', 'kd' : 'StorageClass', 'c1' : 'Comment', 'ss' : 'Delimiter', 'vi' : 'Identifier'}
    for a in keys(syndef)
      if has_key(a:node.attr, 'class') && a:node.attr['class'] == a | let syntax = syndef[a] | endif
    endfor
    if has_key(a:node.attr, 'class') && a:node.attr['class'] == 'line' | echon "\n" | endif
    for c in a:node.child
      call s:dump(c, syntax)
      unlet c
    endfor
  endif
endfunction

let no = 357275
let json = iconv(system("curl -s http://gist.github.com/".no.".json"), 'utf-8', 'cp932')
let true = 1
let false = 0
let null = 0
silent unlet! doc
let doc = ParseXml(eval(json)['div'])
echo "-------------------------------------------------"
for file in doc.findAll('div')
  unlet! meta
  let meta = file.findAll('div')
  if len(meta) > 1
    echo "URL:".meta[1].find('a').attr['href']
  endif
  echo "\n"
  call s:dump(file.find('div').find('div').find('pre'), '')
  echo "-------------------------------------------------"
endfor

" vim: set et:
