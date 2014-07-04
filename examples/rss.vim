exec 'so '.expand('<sfile>:h').'/../xmlparse.vim'

let xml = system('curl -s http://mattn.kaoriya.net/index.rss')
silent unlet! doc
let doc = xmlparser#ParseXml(xml)

for item in doc.childNode('channel').childNodes('item')
  echo item.childNode('title').value()
  echo item.childNode('link').value()
  echo "\n"
endfor
