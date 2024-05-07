extends Stmt
class_name SkyPrint

var expr: Expr


func _init(_expr: Expr) -> void:
	expr = _expr

func accept(visitor: BaseVisitor):
	return visitor.visit_sky_print_stmt(self)
