extends Stmt
class_name If

var condition: Expr
var then_branch: Stmt
var else_branch: Stmt


func _init(_condition: Expr, _then_branch: Stmt, _else_branch: Stmt) -> void:
	condition = _condition
	then_branch = _then_branch
	else_branch = _else_branch

func accept(visitor: BaseVisitor):
	return visitor.visit_if_stmt(self)
