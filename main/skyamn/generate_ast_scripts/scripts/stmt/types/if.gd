extends Stmt
class_name If

var condition: Expr
var then_branch: Array[Stmt]
var else_branch: Array[Stmt]


func _init(_condition: Expr, _then_branch: Array[Stmt], _else_branch: Array[Stmt]) -> void:
	condition = _condition
	then_branch = _then_branch
	else_branch = _else_branch

func accept(visitor: BaseVisitor):
	return visitor.visit_if_stmt(self)
