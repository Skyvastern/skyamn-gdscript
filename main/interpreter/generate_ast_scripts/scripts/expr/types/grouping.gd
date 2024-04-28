extends Expr
class_name Grouping

var expression: Expr


func _init(_expression: Expr) -> void:
	expression = _expression

func accept(visitor: ExprVisitor):
	return visitor.visit_grouping_expr(self)
