so ../xmlparse.vim

let xml = system('curl -s http://mattn.kaoriya.net/index.rss')
let xml = iconv(xml, 'utf-8', &encoding)
silent unlet! doc
let doc = ParseXml(xml)

for item in doc.find('channel').findAll('item')
  echo item.find('title').value
  echo item.find('link').value
  echo "\n"
endfor
