extends Stmt
class_name While

var condition: Expr
var body: Stmt


func _init(_condition: Expr, _body: Stmt) -> void:
	condition = _condition
	body = _body

func accept(visitor: BaseVisitor):
	return visitor.visit_while_stmt(self)
