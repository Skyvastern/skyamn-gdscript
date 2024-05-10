extends Stmt
class_name Block

var statements: Array[Stmt]


func _init(_statements: Array[Stmt]) -> void:
	statements = _statements

func accept(visitor: BaseVisitor):
	return visitor.visit_block_stmt(self)
