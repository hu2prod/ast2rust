assert = require 'assert'
require "fy"

mod = require '../src/index.coffee'
gen = mod.gen
Type = require 'type'
ast = require 'ast4gen'

cst = (type, val)->
  t = new ast.Const
  t.val = val
  t.type = new Type type
  t

var_d = (name, scope, type='int')->
  scope.list.push t = new ast.Var_decl
  t.name = name
  t.type = new Type type
  
  t = new ast.Var
  t.name = name
  t.type = new Type type
  t

describe 'index section', ()->
  it 'self', ()->
    assert.equal gen(new ast.This), "self"
    return
  
  it 'true', ()->
    scope = new ast.Scope
    scope.list.push cst "bool", 'true'
    assert.equal gen(scope), 'true'
    return
  
  it '1', ()->
    scope = new ast.Scope
    scope.list.push cst "int", '1'
    assert.equal gen(scope), '1'
    return
  
  it '1.1', ()->
    scope = new ast.Scope
    scope.list.push cst "float", '1.1'
    assert.equal gen(scope), '1.1'
    return
  
  it '"1"', ()->
    scope = new ast.Scope
    scope.list.push cst "string", '1'
    assert.equal gen(scope), '"1"'
    return
  
  it 'var decl bool', ()->
    scope = new ast.Scope
    scope.list.push t = new ast.Var_decl
    t.name = 'a'
    t.type = new Type "bool"
    assert.equal gen(scope), "let mut a:bool"
    return
  
  it 'var decl int', ()->
    scope = new ast.Scope
    scope.list.push t = new ast.Var_decl
    t.name = 'a'
    t.type = new Type "int"
    assert.equal gen(scope), "let mut a:u64"
    return
  
  it 'var decl float', ()->
    scope = new ast.Scope
    scope.list.push t = new ast.Var_decl
    t.name = 'a'
    t.type = new Type "float"
    assert.equal gen(scope), "let mut a:f64"
    return
  
  it 'var decl string', ()->
    scope = new ast.Scope
    scope.list.push t = new ast.Var_decl
    t.name = 'a'
    t.type = new Type "string"
    assert.equal gen(scope), "let mut a:&str"
    return
  
