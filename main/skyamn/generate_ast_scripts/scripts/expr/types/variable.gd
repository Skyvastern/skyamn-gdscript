extends Expr
class_name Variable

var token_name: Token


func _init(_token_name: Token) -> void:
	token_name = _token_name

func accept(visitor: BaseVisitor):
	return visitor.visit_variable_expr(self)
