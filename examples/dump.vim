exec 'so '.expand('<sfile>:h').'/../xmlparse.vim'

function! s:dump(node, indent)
  echo repeat(' ',a:indent).a:node.name
  for attr in keys(a:node.attr)
    echo repeat(' ',a:indent + 2).'* '.attr.'='.a:node.attr[attr]
  endfor
  for child in a:node.child
    call s:dump(child, a:indent + 4)
  endfor
  if len(a:node.value)
    echo repeat(' ',a:indent + 2).'- '.a:node.value
  endif
endfunction

let xml = system('curl -s http://feeds.digg.com/digg/popular.rss')
silent unlet! doc
let doc = ParseXml(xml)
call s:dump(doc, 0)
