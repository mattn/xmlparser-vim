function! s:ParseTree(xml)
  let mx = '^\%([ \t\r\n]*\)\(<?\{0,1}[^>]\+>\)'
  let str = a:xml
  let nodes = []

  while len(str) > 0
    let match = matchstr(str, mx)
    if len(match) == 0
      break
    endif
    let tag = substitute(match, mx, '\1', 'i')
    let node = { 'name': '', 'attr': {}, 'child': [], 'value': '' }
    let tag_mx = '<\([^ \t\r\n/>]*\)\(\%(\s*[^ \t\r\n=]\+\s*=\s*\%([^"'' \t]\+\|["''][^"'']\+["'']\)\s*\)*\)\s*/*>'
    let tag_match = matchstr(tag, tag_mx)
    let node.name = substitute(tag_match, tag_mx, '\1', 'i')
    let attrs = substitute(tag_match, tag_mx, '\2', 'i')
    let attr_mx = '\([^ \t\r\n=]\+\)\s*=\s*["'']\{0,1}\([^"'' \t]\+\|[^"'']\+\)["'']\{0,1}'
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

    function! node.findAll(name) dict
      let ret = []
      for c in self.child
        if c.name == a:name
          call add(ret, c)
        endif
      endfor
	  return ret
    endfunction

    if len(node.name) > 0
      call add(nodes, node)
      if match !~ '\/>$'
        let pair = matchstr(str, '</'.node.name.'[^>]*>')
        let inner = str[:stridx(str, pair)-1]
        let inner = inner[stridx(str, match) + len(match):]
		let child = s:ParseTree(inner)
		if len(child)
          let node.child = child
        else
          let inner = substitute(inner, '&gt;', '>', 'g')
          let inner = substitute(inner, '&lt;', '<', 'g')
          let inner = substitute(inner, '&quot;', '"', 'g')
          let inner = substitute(inner, '&apos;', "'", 'g')
          let inner = substitute(inner, '&nbsp;', ' ', 'g')
          let inner = substitute(inner, '&yen;', '\&#65509;', 'g')
          let inner = substitute(inner, '&#\(\d\+\);', '\=s:nr2enc_char(submatch(1))', 'g')
          let inner = substitute(inner, '&amp;', '\&', 'g')
          let node.value = inner
        endif
		if len(inner)
          let str = str[stridx(str, inner) + len(inner):-len(pair)]
        else
		  let str = ''
        endif
        continue
      endif
    endif
    let str = str[stridx(str, match) + len(match):]
  endwhile
  return nodes
endfunction

function! ParseXml(xml)
  let nodes = s:ParseTree(a:xml)
  return nodes[0]
endfunction
