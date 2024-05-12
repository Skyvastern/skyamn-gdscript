extends Expr
class_name Call

var callee: Expr
var paren: Token
var arguments: Array[Expr]


func _init(_callee: Expr, _paren: Token, _arguments: Array[Expr]) -> void:
	callee = _callee
	paren = _paren
	arguments = _arguments

func accept(visitor: BaseVisitor):
	return visitor.visit_call_expr(self)
