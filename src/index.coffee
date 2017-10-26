require 'fy/codegen'

module = @

class @Gen_context

@gen = gen = (ast, ctx = new module.Gen_context)->
  switch ast.constructor.name
    # ###################################################################################################
    #    expr
    # ###################################################################################################
    when "This"
      "self"
    
    when "Const"
      switch ast.type.main
        when 'bool', 'int', 'float'
          ast.val
        when 'string'
          JSON.stringify ast.val
    
     when "Var"
      ast.name
    
   # ###################################################################################################
    #    stmt
    # ###################################################################################################
    when "Scope"
      jl = []
      for v in ast.list
        t = gen v, ctx
        jl.push t if t != ''
      jl.join ";\n"
    
    when "Var_decl"
      type = switch ast.type.main
        when "bool"
          "bool"
        when "int"
          "u64"
        when "float"
          "f64"
        when "string"
          "&str"
      "let mut #{ast.name}:#{type}"
