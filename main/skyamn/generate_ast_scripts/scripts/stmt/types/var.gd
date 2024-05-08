extends Stmt
class_name Var

var token_name: Token
var initializer: Expr


func _init(_token_name: Token, _initializer: Expr) -> void:
	token_name = _token_name
	initializer = _initializer

func accept(visitor: BaseVisitor):
	return visitor.visit_var_stmt(self)
