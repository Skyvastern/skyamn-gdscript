extends BaseVisitor
class_name ExprVisitor


func visit_binary_expr(_binary: Binary):
	pass

func visit_grouping_expr(_grouping: Grouping):
	pass

func visit_literal_expr(_literal: Literal):
	pass

func visit_unary_expr(_unary: Unary):
	pass
