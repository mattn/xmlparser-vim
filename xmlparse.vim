function! s:parseXml(xml)
  let mx = '^\%(\s*\)\(<?\{0,1}[^>]\+>\)'
  let str = a:xml
  let nodes = []

  let is_top = 0
  if matchstr(str, mx) =~ '^<?'
    let is_top = 1
  endif
  while len(str) > 0
    let match = matchstr(str, mx)
    if len(match) == 0
      break
    endif
    let tag = substitute(match, mx, '\1', 'i')
    let node = { 'name': '', 'attr': {}, 'child': [], 'value': '' }
    let tag_mx = '<\([a-zA-Z][a-zA-Z0-9_]*\)\(\%(\s[a-zA-Z][a-zA-Z0-9_]\+=\%([^"'' \t]\+\|["''][^"'']\+["'']\)\s*\)*\)\s*/*>'
    let tag_match = matchstr(tag, tag_mx)
    let node.name = substitute(tag_match, tag_mx, '\1', 'i')
    let attrs = substitute(tag_match, tag_mx, '\2', 'i')
    let attr_mx = '\([a-zA-Z0-9_]\+\)=["'']\{0,1}\([^"'' \t]\+\|[^"'']\+\)["'']\{0,1}'
    while len(attrs) > 0
      let tag_match = matchstr(attrs, attr_mx)
      if len(tag_match) == 0
        break
      endif
      let name = substitute(tag_match, attr_mx, '\1', 'i')
      let value = substitute(tag_match, attr_mx, '\2', 'i')
      let node.attr[name] = value
      let attrs = attrs[stridx(attrs, tag_match) + len(tag_match):]
    endwhile

    function! node.find(name) dict
      for c in self.child
        if c.name == a:name
          return c
        endif
      endfor
    endfunction

    if len(node.name) > 0
      call add(nodes, node)
      if match !~ '\/>$'
        let rest = matchstr(str, '</'.node.name.'[^>]*>')
        let inner = str[:stridx(str, rest)-1]
        let inner = inner[stridx(str, match) + len(match):]
        let node.child = s:parseXml(inner)
        let str = str[stridx(str, inner) + len(inner):]
        continue
      endif
    endif
    let str = str[stridx(str, match) + len(match):]
  endwhile
  if is_top
    return nodes[0]
  else
    return nodes
  endif
endfunction

if exists('g:xmlparse_debug')
  function! s:dump(node, indent)
    echo repeat(' ',a:indent).a:node.name
    for attr in keys(a:node.attr)
      echo repeat(' ',a:indent + 2).'* '.attr.'='.a:node.attr[attr]
    endfor
    for child in a:node.child
      call s:dump(child, a:indent + 4)
    endfor
  endfunction

  let loc = 'Osaka'
  let xml = system('curl -s http://www.google.com/ig/api?weather='.loc)
  unlet! doc
  let doc = s:parseXml(xml)
  echo loc.'''s current weather is '.doc.find('weather').find('current_conditions').find('condition').attr['data']

  " 2010/03/12 11:15:00 JST
  " Osaka's current weather is Clear
endif
