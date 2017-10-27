require 'fy/codegen'

module = @
@bin_op_name_map =
  ADD : '+'
  SUB : '-'
  MUL : '*'
  DIV : '/'
  MOD : '%'
  POW : '**'
  
  BIT_AND : '&'
  BIT_OR  : '|'
  BIT_XOR : '^'
  
  BOOL_AND : '&&'
  BOOL_OR  : '||'
  # BOOL_XOR : '^'
  
  SHR : '>>'
  SHL : '<<'
  LSR : '>>>' # логический сдвиг вправо >>>
  
  ASSIGN : '='
  ASS_ADD : '+='
  ASS_SUB : '-='
  ASS_MUL : '*='
  ASS_DIV : '/='
  ASS_MOD : '%='
  ASS_POW : '**='
  
  ASS_SHR : '>>='
  ASS_SHL : '<<='
  ASS_LSR : '>>>=' # логический сдвиг вправо >>>
  
  ASS_BIT_AND : '&='
  ASS_BIT_OR  : '|='
  ASS_BIT_XOR : '^='
  
  # ASS_BOOL_AND : ''
  # ASS_BOOL_OR  : ''
  # ASS_BOOL_XOR : ''
  
  EQ : '=='
  NE : '!='
  GT : '>'
  LT : '<'
  GTE: '>='
  LTE: '<='

@bin_op_name_cb_map =
  BOOL_XOR      : (a, b)->"!!(#{a} ^ #{b})"
  ASS_BOOL_AND  : (a, b)->"(#{a} = !!(#{a} & #{b}))"
  ASS_BOOL_OR   : (a, b)->"(#{a} = !!(#{a} | #{b}))"
  ASS_BOOL_XOR  : (a, b)->"(#{a} = !!(#{a} ^ #{b}))"
  
@un_op_name_cb_map =
  INC_RET : (a)->"++(#{a})"
  RET_INC : (a)->"(#{a})++"
  DEC_RET : (a)->"--(#{a})"
  RET_DEC : (a)->"(#{a})--"
  BOOL_NOT: (a)->"!(#{a})"
  BIT_NOT : (a)->"~(#{a})"
  MINUS   : (a)->"-(#{a})"
  PLUS    : (a)->"+(#{a})"

class @Gen_context
  in_class : false
  mk_nest : ()->
    t = new module.Gen_context
    t

@gen = gen = (ast, ctx = new module.Gen_context)->
  switch ast.constructor.name
    # ###################################################################################################
    #    expr
    # ###################################################################################################
    when "This"
      "@"
    
    when "Const"
      switch ast.type.main
        when 'bool', 'int', 'float'
          ast.val
        when 'string'
          JSON.stringify ast.val
    
    when "Array_init"
      jl = []
      for v in ast.list
        jl.push gen v, ctx
      "[#{jl.join ', '}]"
    
    when "Hash_init", "Struct_init"
      jl = []
      for k,v of ast.hash
        jl.push "#{JSON.stringify k}: #{gen v, ctx}"
      "{#{jl.join ', '}}"
    
    when "Var"
      ast.name
    
    when "Bin_op"
      _a = gen ast.a, ctx
      _b = gen ast.b, ctx
      if op = module.bin_op_name_map[ast.op]
        "(#{_a} #{op} #{_b})"
      else
        module.bin_op_name_cb_map[ast.op](_a, _b)
    
    when "Un_op"
      module.un_op_name_cb_map[ast.op] gen ast.a, ctx
    
    when "Field_access"
      "(#{gen(ast.t, ctx)}).#{ast.name}"
    
    when "Fn_call"
      jl = []
      for v in ast.arg_list
        jl.push gen v, ctx
      "(#{gen ast.fn, ctx})(#{jl.join ', '})"
    # ###################################################################################################
    #    stmt
    # ###################################################################################################
    when "Scope"
      jl = []
      for v in ast.list
        t = gen v, ctx
        jl.push t if t != ''
      jl.join "\n"
    
    when "If"
      cond = gen ast.cond, ctx
      t = gen ast.t, ctx
      f = gen ast.f, ctx
      if f == ''
        """
        if #{cond}
          #{make_tab t, '  '}
        """
      else if t == ''
        """
        unless #{cond}
          #{make_tab f, '  '}
        """
      else
        """
        if #{cond}
          #{make_tab t, '  '}
        else
          #{make_tab f, '  '}
        """
    
    when "Switch"
      jl = []
      for k,v of ast.hash
        if ast.cond.type.main == 'string'
          k = JSON.stringify k
        jl.push """
        when #{k}
          #{make_tab gen(v, ctx) or '0', '  '}
        """
      
      if "" != f = gen ast.f, ctx
        jl.push """
        else
          #{make_tab f, '  '}
        """
      
      """
      switch #{gen ast.cond, ctx}
        #{join_list jl, '  '}
      """
    
    when "Loop"
      """
      loop
        #{make_tab gen(ast.scope, ctx), '  '}
      """
    
    when "While"
      """
      while #{gen ast.cond, ctx}
        #{make_tab gen(ast.scope, ctx), '  '}
      """
    
    when "Break"
      "break"
    
    when "Continue"
      "continue"
    
    when "For_range"
      aux_step = ""
      if ast.step
        aux_step = " by #{gen ast.step, ctx}"
      ranger = if ast.exclusive then "..." else ".."
      """
      for #{gen ast.i, ctx} in [#{gen ast.a, ctx} #{ranger} #{gen ast.b, ctx}]#{aux_step}
        #{make_tab gen(ast.scope, ctx), '  '}
      """
    
    when "For_array"
      if ast.v
        aux_v = gen ast.v, ctx
      else
        aux_v = "_skip"
      
      aux_k = ""
      if ast.k
        aux_k = ",#{gen ast.k, ctx}"
      """
      for #{aux_v}#{aux_k} in #{gen ast.t, ctx}
        #{make_tab gen(ast.scope, ctx), '  '}
      """
    
    when "For_hash"
      if ast.k
        aux_k = gen ast.k, ctx
      else
        aux_k = "_skip"
      
      aux_v = ""
      if ast.v
        aux_v = ",#{gen ast.v, ctx}"
      """
      for #{aux_k}#{aux_v} of #{gen ast.t, ctx}
        #{make_tab gen(ast.scope, ctx), '  '}
      """
    
    when "Ret"
      aux = ""
      if ast.t
        aux = " (#{gen ast.t, ctx})"
      "return#{aux}"
    
    when "Try"
      """
      try
        #{make_tab gen(ast.t, ctx), '  '}
      catch #{ast.exception_var_name}
        #{make_tab gen(ast.c, ctx), '  '}
      """
    
    when "Throw"
      "throw new Error(#{gen ast.t, ctx})"
    
    when "Var_decl"
      ""
    
    when "Class_decl"
      ctx_nest = ctx.mk_nest()
      ctx_nest.in_class = true
      """
      class #{ast.name}
        #{make_tab gen(ast.scope, ctx_nest), '  '}
      """
    
    when "Fn_decl"
      arg_list = ast.arg_name_list
      if ctx.in_class
        """
        #{ast.name} : (#{arg_list.join ', '})->
          #{make_tab gen(ast.scope, ctx), '  '}
        """
      else
        """
        #{ast.name} = (#{arg_list.join ', '})->
          #{make_tab gen(ast.scope, ctx), '  '}
        """
    