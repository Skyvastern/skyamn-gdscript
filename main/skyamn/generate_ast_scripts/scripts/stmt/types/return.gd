extends Stmt
class_name Return

var keyword: Token
var value: Expr


func _init(_keyword: Token, _value: Expr) -> void:
	keyword = _keyword
	value = _value

func accept(visitor: BaseVisitor):
	return visitor.visit_return_stmt(self)
