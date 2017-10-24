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
