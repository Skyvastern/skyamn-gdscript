extends BaseVisitor
class_name Interpreter

var globals: SkyEnvironment = SkyEnvironment.new()
var environment: SkyEnvironment = globals

# emit(message: String)
signal log_message

# emit(token: Token, message: String)
signal runtime_error

var return_value_set: Variant = null


func _init(on_log_message: Callable, on_runtime_error: Callable) -> void:
	log_message.connect(on_log_message)
	runtime_error.connect(on_runtime_error)
	
	globals.define("clock", Clock.new())
	globals.define("abs", MathAbs.new())
	globals.define("acos", MathACos.new())
	globals.define("acosh", MathACosH.new())
	globals.define("asin", MathASin.new())
	globals.define("asinh", MathASinH.new())
	globals.define("atan", MathATan.new())
	globals.define("atan2", MathATan2.new())
	globals.define("atanh", MathATanH.new())
	globals.define("cos", MathCos.new())
	globals.define("deg_to_rad", MathDegToRad.new())
	globals.define("power", MathPower.new())
	globals.define("rad_to_deg", MathRadToDeg.new())
	globals.define("random", MathRandom.new())
	globals.define("sin", MathSin.new())
	globals.define("sqrt", MathSqrt.new())
	globals.define("tan", MathTan.new())


func interpret(statements: Array[Stmt]) -> void:
	for stmt in statements:
		execute(stmt)


func execute(stmt: Stmt) -> void:
	stmt.accept(self)



func visit_sky_expression_stmt(stmt: SkyExpression) -> void:
	evaluate(stmt.expr)


func visit_sky_function_stmt(stmt: SkyFunction):
	var function: SkyamnFunction = SkyamnFunction.new(stmt)
	environment.define(stmt.token_name.lexeme, function)


func visit_if_stmt(stmt: If) -> void:
	for branch in stmt.conditional_branches:
		var condition: Expr = branch["condition"]
		if condition != null:
			if is_truthy(evaluate(condition)):
				execute_block(branch["branch"], SkyEnvironment.new(environment))
				break
		else:
			execute_block(branch["branch"], SkyEnvironment.new(environment))
			break


func visit_sky_print_stmt(stmt: SkyPrint) -> void:
	var value: Variant = evaluate(stmt.expr)
	var output: String = stringify(value)
	emit_log_message(output)


func visit_return_stmt(stmt: Return):
	var value: Variant = null
	if stmt.value != null:
		value = evaluate(stmt.value)
	
	return_value_set = value


func visit_while_stmt(stmt: While) -> void:
	while return_value_set == null and is_truthy(evaluate(stmt.condition)):
		execute_block(stmt.body, SkyEnvironment.new(environment))


func visit_block_stmt(block: Block) -> void:
	execute_block(block.statements, SkyEnvironment.new(environment))


func visit_var_stmt(stmt: Var) -> void:
	var value: Variant = null
	
	if stmt.initializer != null:
		value = evaluate(stmt.initializer)
	
	environment.define(stmt.token_name.lexeme, value)


func execute_block(statements: Array[Stmt], new_environment: SkyEnvironment) -> void:
	var previous_env: SkyEnvironment = environment
	environment = new_environment
	
	for stmt in statements:
		if return_value_set != null:
			break
		
		execute(stmt)
	
	environment = previous_env



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
		check_boolean_unary_operand(unary.operator, right)
		return not is_truthy(right)
	
	return null


func visit_variable_expr(variable: Variable) -> Variant:
	var value: Variant = environment.get_value(variable.token_name)
	
	if value == null:
		emit_runtime_error(variable.token_name, "Variable is not initialized.")
		return null
	
	return value



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
		
		if not left is String:
			left = stringify(left)
		
		if not right is String:
			right = stringify(right)
		
		if left is String and right is String:
			return left + right
		
		emit_runtime_error(binary.operator, "Invalid operands with '+'")
	
	# Subtraction
	if binary.operator.type == Token.TokenType.MINUS:
		if check_number_binary_operands(binary.operator, left, right):
			return float(left) - float(right)
	
	# Multiplication
	if binary.operator.type == Token.TokenType.STAR:
		if check_number_binary_operands(binary.operator, left, right):
			return float(left) * float(right)
	
	# Division
	if binary.operator.type == Token.TokenType.SLASH:
		if check_number_binary_operands(binary.operator, left, right):
			return float(left) / float(right)
	
	# Integer Division
	if binary.operator.type == Token.TokenType.SLASH_SLASH:
		if check_number_binary_operands(binary.operator, left, right):
			return float(int(left/right))
	
	# Modulus
	if binary.operator.type == Token.TokenType.PERCENT:
		if check_number_binary_operands(binary.operator, left, right):
			return float(int(left) % int(right))
	
	# Greater
	if binary.operator.type == Token.TokenType.GREATER:
		if check_number_binary_operands(binary.operator, left, right):
			return float(left) > float(right)
	
	# Greater Equal
	if binary.operator.type == Token.TokenType.GREATER_EQUAL:
		if check_number_binary_operands(binary.operator, left, right):
			return float(left) >= float(right)
	
	# Less
	if binary.operator.type == Token.TokenType.LESS:
		if check_number_binary_operands(binary.operator, left, right):
			return float(left) < float(right)
	
	# Less Equal
	if binary.operator.type == Token.TokenType.LESS_EQUAL:
		if check_number_binary_operands(binary.operator, left, right):
			return float(left) <= float(right)
	
	# Equal To
	if binary.operator.type == Token.TokenType.EQUAL_EQUAL:
		return is_equal(left, right)
	
	# Not Equal To
	if binary.operator.type == Token.TokenType.BANG_EQUAL:
		return not is_equal(left, right)
	
	return null


func visit_call_expr(expr: Call) -> Variant:
	var callee: Variant = evaluate(expr.callee)
	
	var arguments: Array = []
	for arg in expr.arguments:
		arguments.append(
			evaluate(arg)
		)
	
	if not (callee is SkyamnCallable):
		emit_runtime_error(expr.paren, "Can only call functions and classes.")
	
	var function: SkyamnCallable = callee as SkyamnCallable
	
	if arguments.size() != function.arity():
		emit_runtime_error(
			expr.paren,
			"Expected %s arguments, but got %s." % [function.arity(), arguments.size()]
		)
	
	return function.run(self, arguments)


func visit_assign_expr(assign: Assign) -> Variant:
	var value: Variant = evaluate(assign.value)
	var result: bool = environment.assign(assign.token_name, value)
	
	if not result:
		emit_runtime_error(assign.token_name, "Undefined variable.")
	
	return value


func visit_logical_expr(logical: Logical) -> Variant:
	var left: Variant = evaluate(logical.left)
	
	if logical.operator.type == Token.TokenType.OR:
		if is_truthy(left):
			return left
	else:
		if not is_truthy(left):
			return left
	
	return evaluate(logical.right)


func evaluate(expr: Expr) -> Variant:
	return expr.accept(self)


func is_equal(a: Variant, b: Variant) -> bool:
	if typeof(a) != typeof(b):
		return false
	
	return a == b


func check_boolean_unary_operand(operator: Token, operand: Variant) -> void:
	if operand is bool:
		return
	
	emit_runtime_error(operator, "Operand must be a boolean.")


func check_number_unary_operand(operator: Token, operand: Variant) -> void:
	if operand is float:
		return
	
	emit_runtime_error(operator, "Operand must be a number.")


func check_number_binary_operands(operator: Token, left: Variant, right: Variant) -> bool:
	if left is float and right is float:
		return true
	
	emit_runtime_error(operator, "Operands must be a number.")
	return false


func stringify(variant: Variant) -> String:
	if variant == null:
		return "null"
	
	if variant is float:
		var text: String = str(variant)
		if text.ends_with(".0"):
			text = Skyamn.substring(text, 0, text.length() - 2)
		
		return text
	
	return str(variant)


func emit_runtime_error(token: Token, message: String) -> void:
	runtime_error.emit(token, message)
	# TODO: Not sure how to clear the function call stack
	# Instead tried removing this object using free(), but it showed an error


func emit_log_message(message: String) -> void:
	log_message.emit(message)
