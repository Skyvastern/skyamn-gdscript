extends Expr
class_name Literal

var value: String


func _init(_value: String) -> void:
	value = _value

func accept(visitor: ExprVisitor):
	return visitor.visit_literal_expr(self)
