so ../xmlparse.vim

let xml = iconv(join(filter(split(substitute(join(readfile(expand('<sfile>')), "\n"), '.*\nfinish\n', '', ''), '\n', 1), "v:val !~ '^\"'"), "\n"), 'utf-8', &encoding)
silent unlet! doc
let doc = ParseXml(xml)
echo doc.toString()

scriptencoding utf-8
finish
<くだもの>
	<みかん 種類="ミカン科" 産地="和歌山"/>
	<りんご 種類="りんご科" 産地="和歌山"/>
	<バナナ 種類="バショウ科" 産地="フィリピン">まるごとバナナ美味しいよ</バナナ>
	バショウ
</くだもの>
