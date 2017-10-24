assert = require 'assert'

mod = require '../src/index.coffee'
gen = mod.gen
ast = require 'ast4gen'

describe 'index section', ()->
  it 'self', ()->
    assert.equal gen(new ast.This), "self"
    return
  