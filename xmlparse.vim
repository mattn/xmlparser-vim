let s:template = { 'name': '', 'attr': {}, 'child': [] }

function! s:nr2byte(nr)
  if a:nr < 0x80
    return nr2char(a:nr)
  elseif a:nr < 0x800
    return nr2char(a:nr/64+192).nr2char(a:nr%64+128)
  else
    return nr2char(a:nr/4096%16+224).nr2char(a:nr/64%64+128).nr2char(a:nr%64+128)
  endif
endfunction

function! s:nr2enc_char(charcode)
  if &encoding == 'utf-8'
    return nr2char(a:charcode)
  endif
  let char = s:nr2byte(a:charcode)
  if strlen(char) > 1
    let char = strtrans(iconv(char, 'utf-8', &encoding))
  endif
  return char
endfunction

function! s:nr2hex(nr)
  let n = a:nr
  let r = ""
  while n
    let r = '0123456789ABCDEF'[n % 16] . r
    let n = n / 16
  endwhile
  return r
endfunction

function! s:encodeURIComponent(instr)
  let instr = iconv(a:instr, &enc, "utf-8")
  let len = strlen(instr)
  let i = 0
  let outstr = ''
  while i < len
    let ch = instr[i]
    if ch =~# '[0-9A-Za-z-._~!''()*]'
      let outstr .= ch
    elseif ch == ' '
      let outstr .= '+'
    else
      let outstr .= '%' . substitute('0' . s:nr2hex(char2nr(ch)), '^.*\(..\)$', '\1', '')
    endif
    let i = i + 1
  endwhile
  return outstr
endfunction

function! s:decodeEntityReference(str)
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

function! s:encodeEntityReference(str)
  let str = a:str
  let str = substitute(str, '&', '\&amp;', 'g')
  let str = substitute(str, '>', '&gt;', 'g')
  let str = substitute(str, '<', '&lt;', 'g')
  let str = substitute(str, '"', '&quot;', 'g')
  let str = substitute(str, "'", '&apos;', 'g')
  let str = substitute(str, ' ', '&nbsp;', 'g')
  return str
endfunction

function! s:template.childNodes() dict
  let ret = []
  for c in self.child
    if type(c) == 4
      let ret += [c]
    endif
    unlet c
  endfor
  return ret
endfunction

function! s:template.value() dict
  let ret = ''
  for c in self.child
    if type(c) == 1
      let ret .= c
    endif
    unlet c
  endfor
  return ret
endfunction

function! s:template.find(name) dict
  for c in self.child
    if type(c) == 4 && c.name == a:name
      return c
    endif
    " TODO: XPath
    "unlet! ret
    "let ret = c.find(a:name)
    "if type(ret) == 4
    "  return ret
    "endif
    unlet c
  endfor
  return {}
endfunction

function! s:template.findAll(name) dict
  let ret = []
  for c in self.child
    if type(c) == 4 && c.name == a:name
      call add(ret, c)
    endif
    " TODO: XPath
    "let ret += c.findAll(a:name)
    unlet c
  endfor
  return ret
endfunction

function! s:template.toString() dict
  let xml = '<' . self.name
  for attr in keys(self.attr)
    let xml .= ' ' . attr . '="' . self.attr[attr] . '"'
  endfor
  if len(self.child)
    let xml .= '>'
    for c in self.child
      if type(c) == 4
        let xml .= c.toString()
      else
        let xml .= s:encodeEntityReference(string(c))
      endif
      unlet c
    endfor
    let xml .= '</' . self.name . '>'
  elseif len(self.value)
    let xml .= '>' . s:encodeEntityReference(self.value)
    let xml .= '</' . self.name . '>'
  else
    let xml .= ' />'
  endif
  return xml
endfunction

function! s:ParseTree(ctx, top)
  let node = a:top
  let stack = [a:top]
  let pos = 0

  let mx = '^\s*\(<?xml[^>]\+>\)'
  if a:ctx['xml'] =~ mx
    let match = matchstr(a:ctx['xml'], mx)
    let a:ctx['xml'] = a:ctx['xml'][stridx(a:ctx['xml'], match) + len(match):]
    let mx = 'encoding\s*=\s*["'']\{0,1}\([^"'' \t]\+\|[^"'']\+\)["'']\{0,1}'
    let match = matchstr(match, mx)
    let encoding = substitute(match, mx, '\1', '')
    if len(encoding) && len(a:ctx['encoding']) == 0
      let a:ctx['encoding'] = encoding
      let a:ctx['xml'] = iconv(a:ctx['xml'], encoding, &encoding)
    endif
  endif
  let mx = '\(<[^>]\+>\)'

  let tag_mx = '<\([^ \t\r\n>]*\)\(\%(\s*[^ \t\r\n=]\+\s*=\s*\%([^"'' \t]\+\|["''][^"'']\+["'']\)\s*\)*\)\s*/*>'
  while len(a:ctx['xml']) > 0
    let tag_match = matchstr(a:ctx['xml'], tag_mx)
    if len(tag_match) == 0
      break
    endif

    let tag_name = substitute(tag_match, tag_mx, '\1', 'i')
    if tag_name[0] == '/'
      let pos = stridx(a:ctx['xml'], tag_match)
      if pos > 0
        call add(stack[-1].child, s:decodeEntityReference(a:ctx['xml'][:stridx(a:ctx['xml'], tag_match) - 1]))
      endif
      call remove(stack, -1)
      let a:ctx['xml'] = a:ctx['xml'][stridx(a:ctx['xml'], tag_match) + len(tag_match):]
      continue
    endif

    call add(stack[-1].child, s:decodeEntityReference(a:ctx['xml'][:stridx(a:ctx['xml'], tag_match) - 1]))

    let node = deepcopy(s:template)
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

    call add(stack[-1].child, node)
    if tag_match[-2:] != '/>'
      call add(stack, node)
    endif
    let a:ctx['xml'] = a:ctx['xml'][stridx(a:ctx['xml'], tag_match) + len(tag_match):]
  endwhile
endfunction

function! ParseXml(xml)
  let top = deepcopy(s:template)
  call s:ParseTree({'xml': a:xml, 'encoding': ''}, top)
  for node in top.child
    if type(node) == 4
      return node
    endif
    unlet node
  endfor
  throw "Parse Error"
endfunction

" vim:set et:
