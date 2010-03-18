exec 'so '.expand('<sfile>:h').'/../xmlparse.vim'

let xml = system('curl -s http://mattn.kaoriya.net/index.rss')
silent unlet! doc
let doc = ParseXml(xml)

for item in doc.find('channel').findAll('item')
  echo item.find('title').value()
  echo item.find('link').value()
  echo "\n"
endfor
