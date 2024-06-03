extends Stmt
class_name If

var conditional_branches: Array[Dictionary]


func _init(_conditional_branches: Array[Dictionary]) -> void:
	conditional_branches = _conditional_branches

func accept(visitor: BaseVisitor):
	return visitor.visit_if_stmt(self)
