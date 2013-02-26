shotgun = require '..'
assert = require 'assert'

combinations = shotgun.combinations

describe "combinations", ->

  it "always returns an array", ->
    cs = do combinations
    assert cs instanceof Array

    cs = combinations []
    assert cs instanceof Array

    cs = combinations [], [10]
    assert cs instanceof Array

    cs = combinations [10], []
    assert cs instanceof Array

    cs = combinations [10], [20]
    assert cs instanceof Array

    cs = combinations [10], [20, 30]
    assert cs instanceof Array

  it "returns empty array if called with no arguments", ->
    cs = do combinations
    assert cs.length == 0

  it "returns empty array if any argument is empty", ->
    cs = combinations []
    assert cs.length == 0

    cs = combinations [], [10]
    assert cs.length == 0

    cs = combinations [10], []
    assert cs.length == 0

    cs = combinations [20, 30], [], [10]
    assert cs.length == 0

  it "returns an array of arrays even with a single argument", ->
    cs = combinations [10]
    assert cs.length == 1
    assert cs[0] instanceof Array

    cs = combinations [10, 20]
    assert cs.length == 2
    assert cs[0] instanceof Array
    assert cs[1] instanceof Array

  it "returns all combinations of values from arguments", ->
    cs = combinations [10]
    assert cs[0][0] == 10

    cs = combinations [10, 20]
    assert cs[0][0] == 10
    assert cs[1][0] == 20

    cs = combinations [10], [20]
    assert cs.length == 1
    assert cs[0].length == 2
    assert cs[0][0] == 10
    assert cs[0][1] == 20

    cs = combinations [10], [20, 30]
    assert cs.length == 2
    assert cs[0].length == 2
    assert cs[0][0] == 10
    assert cs[0][1] == 20
    assert cs[1].length == 2
    assert cs[1][0] == 10
    assert cs[1][1] == 30

    cs = combinations [10], [20], [30]
    assert cs.length == 1
    assert cs[0].length == 3
    assert cs[0][0] == 10
    assert cs[0][1] == 20
    assert cs[0][2] == 30

