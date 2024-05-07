extends Expr
class_name Binary

var left: Expr
var operator: Token
var right: Expr


func _init(_left: Expr, _operator: Token, _right: Expr) -> void:
	left = _left
	operator = _operator
	right = _right

func accept(visitor: BaseVisitor):
	return visitor.visit_binary_expr(self)
