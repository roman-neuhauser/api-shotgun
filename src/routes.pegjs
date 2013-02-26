specs     = spec*

spec      = m:method HS p:path NL ps:params? NL*
{
  return { method: m, path: p[0], params: p[1].concat(ps) };
}

method    = 'DELETE' / 'GET' / 'POST' / 'PUT'

path      = p: ('/' pathseg)+
{
  var path = [], params = []
  for (var i = 0; i < p.length; ++i) {
    var seg = p[i][1]
    if (seg[0] == ':') {
      params.push([seg.substr(1), seg.substr(1)])
    }
    path.push(p[i].join(''))
  }
  return [path.join(''), params]
}

pathseg   = p: pcode    { return ':' + p; }
          / p: segment  { return       p; }

segment   = p: [._0-9a-z]+ { return p.join(''); }

params    = param*

param     = HS p:(mparam / oparam) { return p; }

mparam    = '!' HS p:pbody { return p; }

oparam    = '?' HS p:pbody { return p; }

pbody     = n:pname HS '=' HS c:pcode NL { return [n, c]; }

pname     =     p: [a-z_]+ { return p.join(''); }
pcode     = ':' p: [a-z_]+ { return p.join(''); }

HS        = [ \t]+
NL        = "\n"
