extends Stmt
class_name While

var condition: Expr
var body: Array[Stmt]


func _init(_condition: Expr, _body: Array[Stmt]) -> void:
	condition = _condition
	body = _body

func accept(visitor: BaseVisitor):
	return visitor.visit_while_stmt(self)
