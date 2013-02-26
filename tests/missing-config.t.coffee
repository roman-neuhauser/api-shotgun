shotgun = require '..'
assert = require 'assert'

MissingConfig = shotgun.MissingConfig

describe "MissingConfig", ->

  it "is an Error", ->
    assert new MissingConfig instanceof Error

  it "has a message property", ->
    assert 'message' of new MissingConfig

  it "uses constructor arguments in the message property", ->
    assert.equal \
      "SNAFU FUBAR uses parameter 'WTF' with no configuration."
    , (new MissingConfig 'SNAFU', 'FUBAR', 'WTF').message

  it "has a stack property", ->
    assert 'stack' of new MissingConfig
