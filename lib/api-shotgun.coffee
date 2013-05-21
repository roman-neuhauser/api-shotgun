#!/usr/bin/env coffee

fs     = require 'fs'
http   = require 'http'
path   = require 'path'
qs     = require 'querystring'
util   = require 'util'
parser = require './routes-parser'
log    = require './logging'

mkdir_p = require 'mkdirp'
sprintf = require 'printf'

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

write_response = (path, req, res, body) ->
  txt = sprintf "%s %s %s" \
  , res.statusCode
  , req.method
  , req.path
  txt += "\n\n#{body}" if body
  fs.writeFile path, txt, 'utf8', (e) ->
    log.error new Date, req, e if e

responsepath = (req) ->
  sprintf "response/%s_%s"
  , req.method
  , req.path.replace /\/|\s+/g, (m) ->
    switch m
      when '/' then '.'
      else '_'

_request = http.request

request = (srv, options, done) ->
  log.request new Date, options
  options = extend {}, srv, options
  req = _request options, _respond done
  req.on 'error', done
  req.end()

_respond = (done) -> (res) ->
  body = ''
  res.on 'data', (chunk) ->
    c = chunk.toString()
    body += c
  res.on 'end', ->
    done undefined, body, res

respond = (req) -> (e, body, res) ->
  sig = "#{req.method} #{req.path}"
  ts = new Date
  responsef = responsepath req
  if e
    log.error ts, req, e
    fs.unlink responsef, (e) ->
      log.error new Date, req, e unless e?.code == 'ENOENT'
  else
    log.response ts, req, res
    mkdir_p (path.dirname responsef), (e) ->
      return log.error new Date, req, e if e
      write_response responsef, req, res, body

mkpath = (path, ps) ->
  used = []
  path = path.replace /:(\w+)/g, (_, param) ->
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
    @message = sprintf \
      "%s %s uses parameter '%s' with no configuration."
    , method
    , path
    , parameter
exports.MissingConfig = MissingConfig

exports.process = (srv, routes, params, done) ->

  reqs = {}

  try
    for r in parser.parse routes

      used =
        names: []
        values: []

      for [n, c] in r.params
        if c of params
          used.names.push n
          used.values.push params[c]
        else
          throw new MissingConfig r.method, r.path, c

      unless used.values.length
        addreq reqs, r.method, r.path, []
      else
        for c in combinations used.values...
          ps = ([n, c[i]] for n, i in used.names)
          addreq reqs, r.method, r.path, ps

    for _, req of reqs
      request srv, req, respond req
  catch e
    done e


