let s:template = { 'name': '', 'attr': {}, 'child': [], 'value': '' }

function! l:ch2hex(ch)
  let result = ''
  let i = 0
  while i < strlen(a:ch)
    let hex = AL_nr2hex(char2nr(a:ch[i]))
    let result = result.'%'.(strlen(hex) < 2 ? '0' : '').hex
    let i = i + 1
  endwhile
  return result
endfunction

function! s:UrlEncode(str)
  let retval = a:str
  let retval = substitute(retval, '[^- *.0-9A-Za-z]', '\=l:ch2hex(submatch(0))', 'g')
  let retval = substitute(retval, ' ', '+', 'g')
  return retval
endfunction

function! s:UrlDecode(str)
  let retval = a:str
  let retval = substitute(retval, '+', ' ', 'g')
  let retval = substitute(retval, '%\(\x\x\)', '\=nr2char("0x".submatch(1))', 'g')
  return retval
endfunction

function! s:DecodeEntityReference(str)
  let str = a:str
  let str = substitute(str, '&gt;', '>', 'g')
  let str = substitute(str, '&lt;', '<', 'g')
  let str = substitute(str, '&quot;', '"', 'g')
  let str = substitute(str, '&apos;', "'", 'g')
  let str = substitute(str, '&nbsp;', ' ', 'g')
  let str = substitute(str, '&yen;', '\&#65509;', 'g')
  let str = substitute(str, '&#\(\d\+\);', '\=s:nr2enc_char(submatch(1))', 'g')
  let str = substitute(str, '&amp;', '\&', 'g')
  return str
endfunction

function! s:EncodeEntityReference(str)
  let str = a:str
  let str = substitute(str, '&', '\&amp;', 'g')
  let str = substitute(str, '>', '&gt;', 'g')
  let str = substitute(str, '<', '&lt;', 'g')
  let str = substitute(str, '"', '&quot;', 'g')
  let str = substitute(str, "'", '&apos;', 'g')
  let str = substitute(str, ' ', '&nbsp;', 'g')
  return str
endfunction

function! s:template.find(name) dict
  for c in self.child
    if c.name == a:name
      return c
    endif
	"unlet! ret
	"let ret = c.find(a:name)
	"if type(ret) == 4
    "  return ret
	"endif
  endfor
  return {}
endfunction

function! s:template.findAll(name) dict
  let ret = []
  for c in self.child
    if c.name == a:name
      call add(ret, c)
    endif
	"let ret += child.findAll(a:name)
  endfor
  return ret
endfunction

function! s:template.selectSingleNode(name) dict
  for c in self.child
    if c.name == a:name
      return c
    endif
	unlet! ret
	let ret = c.find(a:name)
	if type(ret) == 4
      return ret
	endif
  endfor
  return {}
endfunction

function! s:template.toString() dict
  let xml = '<' . self.name
  for attr in keys(self.attr)
    let xml .= ' ' . attr . '="' . self.attr[attr] . '"'
  endfor
  if len(self.child)
    let xml .= '>'
    for child in self.child
      let xml .= child.toString()
    endfor
	let xml .= s:EncodeEntityReference(self.value)
    let xml .= '</' . self.name . '>'
  elseif len(self.value)
	let xml .= '>' . s:EncodeEntityReference(self.value)
    let xml .= '</' . self.name . '>'
  else
    let xml .= ' />'
  endif
  return xml
endfunction

function! s:ParseTree(ctx)
  let nodes = []
  let node = {}
  let last = {}
  let pos = 0

  let mx = '^\s*\(<?xml[^>]\+>\)'
  if a:ctx['xml'] =~ mx
    let match = matchstr(a:ctx['xml'], mx)
	let a:ctx['xml'] = a:ctx['xml'][stridx(a:ctx['xml'], match) + len(match):]
  endif
  let mx = '^\%([ \t\r\n]*\)\(<?\{0,1}[^>]\+>\)'
  while len(a:ctx['xml']) > 0
    let match = matchstr(a:ctx['xml'], mx)
    if len(match) == 0
      break
    endif
    let tag = substitute(match, mx, '\1', 'i')
    let node = deepcopy(s:template)
    let tag_mx = '<\([^ \t\r\n/>]*\)\(\%(\s*[^ \t\r\n=]\+\s*=\s*\%([^"'' \t]\+\|["''][^"'']\+["'']\)\s*\)*\)\s*/*>'
    let tag_match = matchstr(tag, tag_mx)
    if len(tag_match) == 0
      let node.value = match
      break
    endif
    let node.name = substitute(tag_match, tag_mx, '\1', 'i')
    let attrs = substitute(tag_match, tag_mx, '\2', 'i')
    let attr_mx = '\([^ \t\r\n=]\+\)\s*=\s*["'']\{0,1}\([^"'' \t]\+\|[^"'']\+\)["'']\{0,1}'
    while len(attrs) > 0
      let attr_match = matchstr(attrs, attr_mx)
      if len(attr_match) == 0
        break
      endif
      let name = substitute(attr_match, attr_mx, '\1', 'i')
      let value = substitute(attr_match, attr_mx, '\2', 'i')
      let node.attr[name] = value
      let attrs = attrs[stridx(attrs, attr_match) + len(attr_match):]
    endwhile

    if len(node.name) > 0
      call add(nodes, node)
      if match !~ '\/>$'
        let pair = matchstr(a:ctx['xml'], '</'.node.name.'[^>]*>')
        let inner = a:ctx['xml'][:stridx(a:ctx['xml'], pair)-1]
        let inner = inner[stridx(a:ctx['xml'], match) + len(match):]
		let cctx = {'xml': inner}
        let child = s:ParseTree(cctx)
		let node.value = cctx.xml
        let a:ctx['xml'] = a:ctx['xml'][stridx(a:ctx['xml'], tag_match) + len(tag_match) + len(inner) + len(pair):]

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
        continue
      endif
    endif
    let a:ctx['xml'] = a:ctx['xml'][stridx(a:ctx['xml'], tag_match) + len(tag_match):]
  endwhile
  return nodes
endfunction

function! ParseXml(xml)
  let nodes = s:ParseTree({"xml": a:xml})
  return nodes[0]
endfunction

" vim:set et
