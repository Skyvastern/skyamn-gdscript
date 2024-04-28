extends ExprVisitor
class_name ASTPrinter


func print_pretty(expr: Expr) -> String:
	return expr.accept(self)


func visit_binary_expr(binary: Binary) -> String:
	return _parenthesis(
		binary.operator.lexeme,
		[
			binary.left,
			binary.right
		]
	)


func visit_grouping_expr(grouping: Grouping) -> String:
	return _parenthesis(
		"group",
		[grouping.expression]
	)


func visit_literal_expr(literal: Literal) -> String:
	if literal.value == "":
		return "null"
	
	return literal.value


func visit_unary_expr(unary: Unary) -> String:
	return _parenthesis(
		unary.operator.lexeme,
		[unary.right]
	)


func _parenthesis(lexeme: String, expressions: Array[Expr]) -> String:
	var result: String = "(" + lexeme
	for e in expressions:
		result += " "
		result += e.accept(self)
	
	result += ")"
	return result
