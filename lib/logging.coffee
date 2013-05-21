# vim: sw=2 sts=2 et

sprintf = require 'printf'

tsfmt = (ts) ->
  sprintf "%d-%02d-%02d %02d:%02d:%02dZ"
  , ts.getUTCFullYear()
  , ts.getUTCMonth()
  , ts.getUTCDate()
  , ts.getUTCHours()
  , ts.getUTCMinutes()
  , ts.getUTCSeconds()

exports.request = (ts, req) ->
  console.log "%s < %s %s"
  , (tsfmt ts)
  , req.method
  , req.path

exports.response = (ts, req, res) ->
  f = if res.statusCode >= 500
    console.error
  else
    console.log
  f "%s > %s %s %s"
  , (tsfmt ts)
  , res.statusCode
  , req.method
  , req.path

exports.error = (ts, req, e) ->
  console.error "%s %s"
  , (tsfmt ts)
  , e

