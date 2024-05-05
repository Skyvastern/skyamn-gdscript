extends Expr
class_name Literal

var value: Variant


func _init(_value: Variant) -> void:
	value = _value

func accept(visitor: ExprVisitor):
	return visitor.visit_literal_expr(self)
