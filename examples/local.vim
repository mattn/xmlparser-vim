so ../xmlparse.vim

function! s:dump(node, indent)
  echo repeat(' ',a:indent).a:node.name
  for attr in keys(a:node.attr)
    echo repeat(' ',a:indent + 2).'* '.attr.'='.a:node.attr[attr]
  endfor
  for child in a:node.child
    call s:dump(child, a:indent + 4)
  endfor
  if len(a:node.value)
    echo repeat(' ',a:indent + 2).'- '.substitute(string(a:node.value), '\n', '\\n', 'g')
  endif
endfunction


let xml = iconv(join(filter(split(substitute(join(readfile(expand('<sfile>')), "\n"), '.*\nfinish\n', '', ''), '\n', 1), "v:val !~ '^\"'"), "\n"), 'utf-8', &encoding)
silent unlet! doc
let doc = ParseXml(xml)
call s:dump(doc, 0)

scriptencoding utf-8
finish
<くだもの>
	<みかん 種類="ミカン科" 産地="和歌山"/>
	<りんご 種類="りんご科" 産地="和歌山"/>
	<バナナ 種類="バショウ科" 産地="フィリピン">まるごとバナナ美味しいよ</バナナ>
	バショウ
</くだもの>
