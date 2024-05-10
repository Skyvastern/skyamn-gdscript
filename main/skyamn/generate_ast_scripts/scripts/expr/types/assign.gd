extends Expr
class_name Assign

var token_name: Token
var value: Expr


func _init(_token_name: Token, _value: Expr) -> void:
	token_name = _token_name
	value = _value

func accept(visitor: BaseVisitor):
	return visitor.visit_assign_expr(self)
