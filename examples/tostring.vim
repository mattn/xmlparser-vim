exec 'so '.expand('<sfile>:h').'/../xmlparse.vim'
scriptencoding utf-8

function! s:dump(node, indent)
  if type(a:node) == 1
    let value = a:node
	let value = substitute(value, "\n", '\\n', 'g')
	let value = substitute(value, "\t", '\\t', 'g')
	let value = substitute(value, '"', '\"', 'g')
    echo repeat(' ',a:indent).'"'.value.'"'
  elseif type(a:node) == 3
    for n in a:node
	  call s:dump(n, a:indent)
    endfor
    return
  elseif type(a:node) == 4
    echo repeat(' ',a:indent).a:node.name
    for attr in keys(a:node.attr)
      echo repeat(' ',a:indent + 2).'* '.attr.'='.a:node.attr[attr]
    endfor
    for child in a:node.child
      call s:dump(child, a:indent + 4)
      unlet child
    endfor
    if len(a:node.value)
      echo repeat(' ',a:indent + 2).'- '.substitute(string(a:node.value), '\n', '\\n', 'g')
    endif
  endif
endfunction

let xml = join(filter(split(substitute(join(readfile(expand('<sfile>')), "\n"), '.*\nfinish\n', '', ''), '\n', 1), "v:val !~ '^\"'"), "\n")
silent unlet! doc
let doc = ParseXml(xml)
call s:dump(doc.find("部類").find("みかん"), 0)
echo doc.find("部類").find("みかん").toString()
call s:dump(doc.find("部類").findAll("みかん"), 0)
call s:dump(doc.find("部類").findAll("りんご"), 0)
call s:dump(doc, 0)

finish
<?xml encoding="utf-8" ?>
<くだもの>
	<部類>
	<みかん 種類="ミカン科1" 産地="和歌山1">
		<みかん 種類="ミカン科2" 産地="和歌山2">
			<みかん 種類="ミカン科3" 産地="和歌山3">ミカン</みかん>
		</みかん>
	</みかん>
	<りんご 種類="りんご科" 産地="和歌山"/>
	<りんご 種類="りんご科" 産地="和歌山"/>
	<バナナ 種類="バショウ科" 産地="フィリピン">まるごと&amp;バナナ美味しいよ</バナナ>
	バショウ
	</部類>
</くだもの>
