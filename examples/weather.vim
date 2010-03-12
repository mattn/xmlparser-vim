so ../xmlparse.vim

let loc = 'Osaka'
let xml = system('curl -s http://www.google.com/ig/api?weather='.loc)
unlet! doc
let doc = ParseXml(xml)
echo loc.'''s current weather is '.doc.find('weather').find('current_conditions').find('condition').attr['data']

" 2010/03/12 11:15:00 JST
" Osaka's current weather is Clear
