exec 'so '.expand('<sfile>:h').'/../xmlparse.vim'
scriptencoding utf-8

let xml = join(filter(split(substitute(join(readfile(expand('<sfile>')), "\n"), '.*\nfinish\n', '', ''), '\n', 1), "v:val !~ '^\"'"), "\n")
silent unlet! doc
let doc = ParseXml(xml)
echo doc.find("ようすけ").name

finish
<?xml encoding="utf-8" ?>
<はせがわ>
	<ようこ></ようこ>
	<ようすけざん></ようすけざん>
	<ようすけ></ようすけ>
	<スケスケ></スケスケ>
</はせがわ>
