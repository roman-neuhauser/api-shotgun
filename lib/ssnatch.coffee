#!/usr/bin/env coffee

http   = require 'http'
qs     = require 'querystring'
util   = require 'util'
parser = require './routes-parser'

httpopts = (meth, path, ps) ->
  ps = ops ps
  [path, ps] = mkpath path, ps
  qstring = mkqs ps
  method: meth
  path: "#{path}#{qstring}"

extend = (dest, sources...) ->
  for src in sources
    for own key, val of src
      dest[key] = val
  dest

_request = http.request

request = (srv, options, done) ->
  return console.log "#{options.method} #{options.path}"
  options = extend {}, srv, options
  req = _request options, (res) ->
    body = ''
    res.on 'data', (chunk) ->
      c = chunk.toString()
      body += c
    res.on 'end', ->
      done undefined, body
  req.on 'error', done
  req.end()

mkpath = (tpl, ps) ->
  used = []
  path = tpl.replace /:(\w+)/g, (_, param) ->
    used.push param
    if ps[param] is undefined then '' else ps[param]
  rv = {}
  rv[p] = ps[p] for p of ps when p not in used
  [path, rv]

mkqs = (ps) ->
  x = {}
  x[n] = v for n, v of ps when v isnt undefined
  rv = qs.stringify x
  if rv.length then "?#{rv}" else rv

ops = (ps) ->
  o = {}
  o[n] = c for [n, c] in ps
  o

exports.combinations = combinations = (arrays...) ->
  return [] unless arrays.length
  ds = []
  arrays.reverse()
  arrays.forEach (a, i, as) ->
    ds[i] = if i == 0 then 1 else ds[i - 1] * as[i - 1].length
  arrays.reverse()
  ds.reverse()
  t = arrays.reduce ((t, v) -> t * v.length), 1
  rv = []
  for n in [0...t]
    thisv = []
    for a, i in arrays
      thisv.push a[(Math.floor n / ds[i]) % a.length]
    rv.push thisv
  rv

addreq = (reqs, meth, path, ps) ->
  req = httpopts meth, path, ps
  reqs["#{req.method} #{req.path}"] = req

exports.SyntaxError = parser.SyntaxError

class MissingConfig extends Error
  constructor: (method, path, parameter) ->
    Error.captureStackTrace this, @constructor
    @message = util.format \
      "%s %s uses parameter '%s' with no configuration."
    , method
    , path
    , parameter
exports.MissingConfig = MissingConfig

exports.process = (srv, routes, params, done) ->

  reqs = {}

  try
    for r in parser.parse routes

      [meth, path, ps] = r

      used =
        names: []
        values: []

      for [n, c] in ps
        if c of params
          used.names.push n
          used.values.push params[c]
        else
          throw new MissingConfig meth, path, c

      unless used.values.length
        addreq reqs, meth, path, []
      else
        for c in combinations used.values...
          ps = ([n, c[i]] for n, i in used.names)
          addreq reqs, meth, path, ps

    for _, req of reqs
      request srv, req, (e, r) ->
        return console.dir e
  catch e
    done e


