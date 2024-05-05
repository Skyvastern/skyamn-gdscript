extends ExprVisitor
class_name Interpreter

# emit(output: String)
signal success

# emit(token: Token, message: String)
signal runtime_error


func _init(on_success: Callable, on_runtime_error: Callable) -> void:
	success.connect(on_success)
	runtime_error.connect(on_runtime_error)


func interpret(expr: Expr) -> void:
	var value: Variant = evaluate(expr)
	var output: String = stringify(value)
	emit_success(output)


func visit_literal_expr(literal: Literal) -> Variant:
	return literal.value


func visit_grouping_expr(grouping: Grouping) -> Variant:
	return evaluate(grouping.expression)


func visit_unary_expr(unary: Unary) -> Variant:
	var right: Variant = evaluate(unary.right)
	
	if unary.operator.type == Token.TokenType.MINUS:
		check_number_unary_operand(unary.operator, right)
		return -float(right)
	
	elif unary.operator.type == Token.TokenType.BANG:
		check_number_unary_operand(unary.operator, right)
		return not is_truthy(right)
	
	return null


func is_truthy(variant: Variant) -> bool:
	if variant == null:
		return false
	
	if variant is bool:
		return bool(variant)
	
	return true


func visit_binary_expr(binary: Binary) -> Variant:
	var left: Variant = evaluate(binary.left)
	var right: Variant = evaluate(binary.right)
	
	# Addition
	if binary.operator.type == Token.TokenType.PLUS:
		if left is float and right is float:
			return float(left) + float(right)
		
		if left is String and right is String:
			return String(left) + String(right)
		
		emit_runtime_error(binary.operator, "Operands must be two numbers or two strings.")
	
	# Subtraction
	if binary.operator.type == Token.TokenType.MINUS:
		check_number_binary_operands(binary.operator, left, right)
		return float(left) - float(right)
	
	# Multiplication
	if binary.operator.type == Token.TokenType.STAR:
		check_number_binary_operands(binary.operator, left, right)
		return float(left) * float(right)
	
	# Division
	if binary.operator.type == Token.TokenType.SLASH:
		check_number_binary_operands(binary.operator, left, right)
		return float(left) / float(right)
	
	# Greater
	if binary.operator.type == Token.TokenType.GREATER:
		check_number_binary_operands(binary.operator, left, right)
		return float(left) > float(right)
	
	# Greater Equal
	if binary.operator.type == Token.TokenType.GREATER_EQUAL:
		check_number_binary_operands(binary.operator, left, right)
		return float(left) >= float(right)
	
	# Less
	if binary.operator.type == Token.TokenType.LESS:
		check_number_binary_operands(binary.operator, left, right)
		return float(left) < float(right)
	
	# Less Equal
	if binary.operator.type == Token.TokenType.LESS_EQUAL:
		check_number_binary_operands(binary.operator, left, right)
		return float(left) <= float(right)
	
	# Equal To
	if binary.operator.type == Token.TokenType.EQUAL_EQUAL:
		return is_equal(left, right)
	
	# Not Equal To
	if binary.operator.type == Token.TokenType.BANG_EQUAL:
		return not is_equal(left, right)
	
	return null


func evaluate(expr: Expr) -> Variant:
	return expr.accept(self)


func is_equal(a: Variant, b: Variant) -> bool:
	if typeof(a) != typeof(b):
		return false
	
	return a == b


func check_number_unary_operand(operator: Token, operand: Variant) -> void:
	if operand is float:
		return
	
	emit_runtime_error(operator, "Operand must be a number.")


func check_number_binary_operands(operator: Token, left: Variant, right: Variant) -> void:
	if left is float and right is float:
		return
	
	emit_runtime_error(operator, "Operands must be a number.")


func stringify(variant: Variant) -> String:
	if variant == null:
		return "null"
	
	if variant is float:
		var text: String = str(variant)
		if text.ends_with(".0"):
			text = Skyashva.substring(text, 0, text.length() - 2)
		
		return text
	
	return String(variant)


func emit_runtime_error(token: Token, message: String) -> void:
	runtime_error.emit(token, message)
	# TODO: Not sure how to clear the function call stack
	# Instead tried removing this object using free(), but it showed an error


func emit_success(output: String) -> void:
	success.emit(output)
