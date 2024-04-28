extends Expr
class_name Unary

var operator: Token
var right: Expr


func _init(_operator: Token, _right: Expr) -> void:
	operator = _operator
	right = _right

func accept(visitor: ExprVisitor):
	return visitor.visit_unary_expr(self)
