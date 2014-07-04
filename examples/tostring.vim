exec 'so '.expand('<sfile>:h').'/../xmlparse.vim'
scriptencoding utf-8

let xml = join(filter(split(substitute(join(readfile(expand('<sfile>')), "\n"), '.*\nfinish\n', '', ''), '\n', 1), "v:val !~ '^\"'"), "\n")
silent unlet! doc
let doc = xmlparser#ParseXml(xml)
echo doc.childNode("部類").childNode("みかん").toString()

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
