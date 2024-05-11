extends BaseVisitor
class_name StmtVisitor


func visit_sky_expression_stmt(_sky_expression: SkyExpression):
	pass

func visit_sky_print_stmt(_sky_print: SkyPrint):
	pass

func visit_var_stmt(_var: Var):
	pass

func visit_block_stmt(_block: Block):
	pass

func visit_if_stmt(_if: If):
	pass

func visit_while_stmt(_while: While):
	pass
