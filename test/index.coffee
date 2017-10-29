require "fy"
assert = require 'assert'

mod = require '../src/index.coffee'
gen = mod.gen
Type = require 'type'
type = (t)->new Type t
ast = require 'ast4gen'

var_d = (name, scope, _type='int')->
  scope.list.push t = new ast.Var_decl
  t.name = name
  t.type = type _type
  
  t = new ast.Var
  t.name = name
  t.type = type _type
  t

_var = (name, scope, _type='int')->
  t = new ast.Var
  t.name = name
  t.type = type _type
  t

cst = (_type, val)->
  t = new ast.Const
  t.val = val
  t.type = type _type
  t

ci = (val)->
  t = new ast.Const
  t.val = val
  t.type = type 'int'
  t

cs = (val)->
  t = new ast.Const
  t.val = val
  t.type = type 'string'
  t

un = (a, op)->
  t = new ast.Un_op
  t.a = a
  t.op= op
  t

bin = (a, op, b)->
  t = new ast.Bin_op
  t.a = a
  t.b = b
  t.op= op
  t

fnd = (name, _type, arg_name_list, scope_list)->
  t = new ast.Fn_decl
  t.name = name
  t.arg_name_list = arg_name_list
  t.type = type _type
  t.scope.list = scope_list
  t

fa = (target, name, _type)->
  t = new ast.Field_access
  t.t = target
  t.name = name
  t.type = type _type
  t

describe 'index section', ->
  it "var x = 5; (js)"#, ->
    # decl = new ast.Var_decl
    # decl.name = "x"
    # decl.type = new Type "int"

    # var_x = new ast.Var
    # var_x.name = "x"
    # var_x.type = new Type "int"

    # const_5 = new ast.Const
    # const_5.val = "5"
    # const_5.type = new Type "int"

    # bin_op = new ast.Bin_op
    # bin_op.op = "ASSIGN"
    # bin_op.a = var_x
    # bin_op.b = const_5
    # bin_op.type = new Type "int"

    # scope = new ast.Scope
    # scope.list.push decl
    # scope.list.push bin_op

    # scope.validate()
    # assert.equal gen(scope), """
    #   let mut x:i32;
    #   (x = 5)
    # """

  it 'self', ->
    assert.equal gen(_var('this', 'int')), "self"
    return
  
  it '1', ->
    scope = new ast.Scope
    scope.list.push cst "int", "1"
    assert.equal gen(scope), "1"
    return
  
  it '1.1', ->
    scope = new ast.Scope
    scope.list.push cst "float", "1.1"
    assert.equal gen(scope), "1.1"
    return
  
  it '"1"', ->
    scope = new ast.Scope
    scope.list.push cst "string", "1"
    assert.equal gen(scope), '"1"'
    return
  
  it 'true', ->
    scope = new ast.Scope
    scope.list.push cst "bool", "true"
    assert.equal gen(scope), "true"
    return
  
  it 'a', ->
    scope = new ast.Scope
    var_a = new ast.Var
    var_a.name = "a"
    # var_a.type = new Type "int"   # unnecessary for this particular test
    scope.list.push var_a
    assert.equal gen(scope), "a"
    return
  
  it '+1'#, ->
    # scope = new ast.Scope
    # c = cst "string", "1"
    # scope.list.push un(c, "PLUS")
    # assert.throws (-> gen scope), /There is no unary PLUS in Rust./
    # return
  
  it '-1', ->
    scope = new ast.Scope
    c = cst "int", "1"
    scope.list.push un(c, "MINUS")
    assert.equal gen(scope), "-(1)"
    return
  
  it '2 + 2', ->
    scope = new ast.Scope
    l = r = cst "int", "2"
    scope.list.push bin(l, "ADD", r)
    assert.equal gen(scope), "(2 + 2)"
    return
  
  it 'true ^ false'#, ->
    # scope = new ast.Scope
    # l = cst "bool", "true"
    # r = cst "bool", "false"
    # scope.list.push bin(l, "BOOL_XOR", r)
    # assert.equal gen(scope), "(true + false)"
    # return
  
  # it '[]', ->
  #   scope = new ast.Scope
  #   scope.list.push t = new ast.Array_init
  #   assert.equal gen(scope), "[]"   # INVALID RUST CODE; type annotation needed
  #   return
  
  it '[1]'#, ->
    # scope = new ast.Scope
    # c = cst "int", "1"
    # scope.list.push t = new ast.Array_init
    # t.list.push c
    # assert.equal gen(scope), "vec![1]"
    # return
  
  # it '{}', ()->
  #   scope = new ast.Scope
  #   scope.list.push t = new ast.Hash_init
  #   assert.equal gen(scope), "{}"
  #   return
  
  # it '{k:a}', ()->
  #   scope = new ast.Scope
  #   a = var_d('a', scope)
  #   scope.list.push t = new ast.Hash_init
  #   t.hash.k = a
  #   assert.equal gen(scope), '{"k": a}'
  #   return
  
  # it '{}', ()->
  #   scope = new ast.Scope
  #   scope.list.push t = new ast.Struct_init
  #   assert.equal gen(scope), "{}"
  #   return
  
  # it '{k:a}', ()->
  #   scope = new ast.Scope
  #   a = var_d('a', scope)
  #   scope.list.push t = new ast.Struct_init
  #   t.hash.k = a
  #   assert.equal gen(scope), '{"k": a}'
  #   return
  
  # it '{k:a}', ()->
  #   scope = new ast.Scope
  #   a = var_d('a', scope)
  #   t = new ast.Struct_init
  #   t.hash.k = a
    
  #   scope.list.push fa(t, 'k', 'int')
  #   assert.equal gen(scope), '({"k": a}).k'
  #   return
  
  it 'f()', ->
    scope = new ast.Scope
    f = var_d('f', scope)
    scope.list.push t = new ast.Fn_call
    t.fn = f
    assert.equal gen(scope), '(f)()'
    return
  
  it 'f(5)', ->
    scope = new ast.Scope
    f = var_d('f', scope)
    c = cst "int", "5"
    scope.list.push t = new ast.Fn_call
    t.fn = f
    t.arg_list.push c
    assert.equal gen(scope), '(f)(5)'
    return
  # ###################################################################################################
  #    stmt
  # ###################################################################################################
  
  it 'if true {5;}'#, ->   # Semicolon is important
    # scope = new ast.Scope
    # cond = cst "bool", "true"
    # c = cst "int", "5"
    # scope.list.push t = new ast.If
    # t.cond = cond
    # t.t.list.push c
    # assert.equal gen(scope), '''
    #   if true {
    #     5;
    #   }
    # '''
    # return
  
  it 'if true {5;} else {2;}'#, ->
    # scope = new ast.Scope
    # cond = cst "bool", "true"
    # c1 = cst "int", "5"
    # c2 = cst "int", "2"
    # scope.list.push t = new ast.If
    # t.cond = cond
    # t.t.list.push c1
    # t.f.list.push c2
    # assert.equal gen(scope), '''
    #   if true {
    #     5;
    #   }
    #   else {
    #     2;
    #   }
    # '''
    # return
  
  it 'if true {} else {2;}'#, ->
    # scope = new ast.Scope
    # cond = cst "bool", "true"
    # c2 = cst "int", "2"
    # scope.list.push t = new ast.If
    # t.cond = cond
    # t.f.list.push c2
    # assert.equal gen(scope), '''
    #   if !(true) {
    #     2;
    #   }
    # '''
    # return
  
  # ###################################################################################################
  # it 'switch a {k:b}', ()->
  #   scope = new ast.Scope
  #   a = var_d('a', scope, 'string')
  #   b = var_d('b', scope)
  #   scope.list.push t = new ast.Switch
  #   t.cond = a
  #   t.hash["k"] = b
  #   assert.equal gen(scope), '''
  #     switch a
  #       when "k"
  #         b
  #   '''
  #   return
  # it 'switch a {k:b}{k2:0}', ()->
  #   scope = new ast.Scope
  #   a = var_d('a', scope, 'string')
  #   b = var_d('b', scope)
  #   scope.list.push t = new ast.Switch
  #   t.cond = a
  #   t.hash["k"] = b
  #   t.hash["k2"] = new ast.Scope
  #   assert.equal gen(scope), '''
  #     switch a
  #       when "k"
  #         b
  #       when "k2"
  #         0
  #   '''
  #   return
  
  # it 'switch a {1:b}', ()->
  #   scope = new ast.Scope
  #   a = var_d('a', scope)
  #   b = var_d('b', scope)
  #   scope.list.push t = new ast.Switch
  #   t.cond = a
  #   t.hash["1"] = b
  #   assert.equal gen(scope), '''
  #     switch a
  #       when 1
  #         b
  #   '''
  #   return
  
  it 'switch 0 {1:2} default{3}'#, ->
    # scope = new ast.Scope
    # a = cst "int", "0"
    # b = cst "int", "2"
    # c = cst "int", "3"
    # scope.list.push t = new ast.Switch
    # t.cond = a
    # t.hash["1"] = b
    # t.f.list.push c
    # assert.equal gen(scope), '''
    #   match 0 {
    #     1 => {b;}
    #     _ => {c;}
    # '''
    # return
  # ###################################################################################################
  it 'loop', ->
    # scope = new ast.Scope
    # a = cst "int", "1"
    # scope.list.push t = new ast.Loop
    # t.scope.list.push a
    # assert.equal gen(scope), '''
    #   loop {
    #     1;
    #   }
    # '''
    # return
  # ###################################################################################################
  it 'while a {b}'#, ->
    # scope = new ast.Scope
    # a = cst "bool", "true"
    # b = cst "int", "1"
    # scope.list.push t = new ast.While
    # t.cond = a
    # t.scope.list.push b
    # assert.equal gen(scope), '''
    #   while a {
    #     b;
    #   }
    # '''
    # return
  
  it 'continue', ()->
    assert.equal gen(new ast.Continue), 'continue'
    return
  
  it 'break', ()->
    assert.equal gen(new ast.Break), 'break'
    return
  # ###################################################################################################
  it 'for i in [1 ... 10] a'#, ()->
    # scope = new ast.Scope
    # i = var_d('i', scope)
    # a = cst "int", "1"
    
    # scope.list.push t = new ast.For_range
    # t.i = i
    # t.a = ci '1'
    # t.b = ci '10'
    # t.scope.list.push a
    # assert.equal gen(scope), '''
    #   for i in 1 ... 10 {
    #     1;
    #   }
    # '''
    # return
  
  # it 'for i in [1 .. 10] a', ()->
  #   scope = new ast.Scope
  #   i = var_d('i', scope)
  #   a = var_d('a', scope)
    
  #   scope.list.push t = new ast.For_range
  #   t.i = i
  #   t.exclusive = false
  #   t.a = ci '1'
  #   t.b = ci '10'
  #   t.scope.list.push a
  #   assert.equal gen(scope), '''
  #     for i in [1 .. 10]
  #       a
  #   '''
  #   return
  
  # it 'for i in [1 .. 10] by 2 a', ()->
  #   scope = new ast.Scope
  #   i = var_d('i', scope)
  #   a = var_d('a', scope)
    
  #   scope.list.push t = new ast.For_range
  #   t.i = i
  #   t.exclusive = false
  #   t.a = ci '1'
  #   t.b = ci '10'
  #   t.step = ci '2'
  #   t.scope.list.push a
  #   assert.equal gen(scope), '''
  #     for i in [1 .. 10] by 2
  #       a
  #   '''
  #   return
  # # ###################################################################################################
  # it 'for v in a b', ()->
  #   scope = new ast.Scope
  #   v = var_d('v', scope)
  #   a = var_d('a', scope)
  #   b = var_d('b', scope)
    
  #   scope.list.push t = new ast.For_col
  #   t.v = v
  #   t.t = a
  #   t.t.type = new Type 'array<int>'
  #   t.scope.list.push b
  #   assert.equal gen(scope), '''
  #     for v in a
  #       b
  #   '''
  #   return
  
  # it 'for v,k in a b', ()->
  #   scope = new ast.Scope
  #   v = var_d('v', scope)
  #   k = var_d('k', scope)
  #   a = var_d('a', scope)
  #   b = var_d('b', scope)
    
  #   scope.list.push t = new ast.For_col
  #   t.k = k
  #   t.v = v
  #   t.t = a
  #   t.t.type = new Type 'array<int>'
  #   t.scope.list.push b
  #   assert.equal gen(scope), '''
  #     for v,k in a
  #       b
  #   '''
  #   return
  
  # it 'for _skip,k in a b', ()->
  #   scope = new ast.Scope
  #   k = var_d('k', scope)
  #   a = var_d('a', scope)
  #   b = var_d('b', scope)
    
  #   scope.list.push t = new ast.For_col
  #   t.k = k
  #   t.t = a
  #   t.t.type = new Type 'array<int>'
  #   t.scope.list.push b
  #   assert.equal gen(scope), '''
  #     for _skip,k in a
  #       b
  #   '''
  #   return
  # # ###################################################################################################
  # it 'for v of a b', ()->
  #   scope = new ast.Scope
  #   v = var_d('v', scope)
  #   a = var_d('a', scope)
  #   b = var_d('b', scope)
    
  #   scope.list.push t = new ast.For_col
  #   t.v = v
  #   t.t = a
  #   t.t.type = new Type 'hash<int>'
  #   t.scope.list.push b
  #   assert.equal gen(scope), '''
  #     for _skip,v of a
  #       b
  #   '''
  #   return
  
  # it 'for v,k of a b', ()->
  #   scope = new ast.Scope
  #   v = var_d('v', scope)
  #   k = var_d('k', scope)
  #   a = var_d('a', scope)
  #   b = var_d('b', scope)
    
  #   scope.list.push t = new ast.For_col
  #   t.k = k
  #   t.v = v
  #   t.t = a
  #   t.t.type = new Type 'hash<int>'
  #   t.scope.list.push b
  #   assert.equal gen(scope), '''
  #     for k,v of a
  #       b
  #   '''
  #   return
  
  # it 'for _skip,k of a b', ()->
  #   scope = new ast.Scope
  #   k = var_d('k', scope)
  #   a = var_d('a', scope)
  #   b = var_d('b', scope)
    
  #   scope.list.push t = new ast.For_col
  #   t.k = k
  #   t.t = a
  #   t.t.type = new Type 'hash<int>'
  #   t.scope.list.push b
  #   assert.equal gen(scope), '''
  #     for k of a
  #       b
  #   '''
  #   return
  # ###################################################################################################
  it 'return', ()->
    scope = new ast.Scope
    scope.list.push t = new ast.Ret
    assert.equal gen(scope), 'return'
    return
  
  it 'return 1', ()->
    scope = new ast.Scope
    scope.list.push t = new ast.Ret
    t.t = ci '1'
    assert.equal gen(scope), 'return (1)'
    return
  # ###################################################################################################
  # it 'try', ()->
  #   scope = new ast.Scope
  #   a = var_d('a', scope)
  #   b = var_d('b', scope)
  #   scope.list.push t = new ast.Try
  #   t.t.list.push a
  #   t.c.list.push b
  #   t.exception_var_name = 'e'
  #   assert.equal gen(scope), '''
  #     try
  #       a
  #     catch e
  #       b
  #   '''
  #   return
  # ###################################################################################################
  it 'panic!("AAAaaaaa!!!!")', ->
    scope = new ast.Scope
    scope.list.push t = new ast.Throw
    t.t = cs "AAAaaaaa!!!!"
    assert.equal gen(scope), 'panic!("AAAaaaaa!!!!")'
    return
  
  it 'Fn_decl'#, ->
    # scope = new ast.Scope
    # scope.list.push fnd('f', type('function<void>'), [], [])
    # assert.equal gen(scope), '''
    #   fn f() {
    #   }
    # '''
    
  # describe 'Class_decl', ()->
  #   it 'Empty', ()->
  #     scope = new ast.Scope
  #     scope.list.push t = new ast.Class_decl
  #     t.name = 'A'
  #     assert.equal gen(scope), 'class A\n  '
    
  #   it 'Method', ()->
  #     scope = new ast.Scope
  #     scope.list.push t = new ast.Class_decl
  #     t.name = 'A'
  #     t.scope.list.push fnd('fn', type('function<void>'), [], [])
  #     assert.equal gen(scope), '''
  #       class A
  #         fn : ()->
            
  #       '''