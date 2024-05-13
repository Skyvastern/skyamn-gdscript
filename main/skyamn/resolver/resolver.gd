extends BaseVisitor
class_name Resolver

var interpreter: Interpreter
var scopes: Array[Dictionary] = []
var current_function: FunctionType = FunctionType.NONE

enum FunctionType {
	NONE,
	FUNCTION
}



func _init(_interpreter: Interpreter) -> void:
	interpreter = _interpreter


func visit_block_stmt(block: Block) -> void:
	begin_scope()
	resolve(block.statements)
	end_scope()


func visit_var_stmt(stmt: Var) -> void:
	declare(stmt.token_name)
	
	if stmt.initializer != null:
		resolve_expr(stmt.initializer)
	
	define(stmt.token_name)


func visit_variable_expr(variable: Variable) -> void:
	if not scopes.is_empty() and scopes[-1].get(variable.token_name.lexeme) == false:
		Skyamn.error_token(variable.token_name, "Can't read local variable in its own initializer.")
	
	resolve_local(variable, variable.token_name)


func visit_assign_expr(assign: Assign) -> void:
	resolve_expr(assign.value)
	resolve_local(assign, assign.token_name)


func visit_sky_function_stmt(stmt: SkyFunction) -> void:
	declare(stmt.token_name)
	define(stmt.token_name)
	resolve_function(stmt, FunctionType.FUNCTION)


func visit_sky_expression_stmt(stmt: SkyExpression) -> void:
	resolve_expr(stmt.expr)


func visit_if_stmt(stmt: If) -> void:
	resolve_expr(stmt.condition)
	resolve_stmt(stmt.then_branch)
	
	if stmt.else_branch != null:
		resolve_stmt(stmt.else_branch)


func visit_sky_print_stmt(stmt: SkyPrint) -> void:
	resolve_expr(stmt.expr)


func visit_return_stmt(stmt: Return) -> void:
	if current_function == FunctionType.NONE:
		Skyamn.error_token(stmt.keyword, "Can't return from top-level code.")
	
	if stmt.value != null:
		resolve_expr(stmt.value)


func visit_while_stmt(stmt: While) -> void:
	resolve_expr(stmt.condition)
	resolve_stmt(stmt.body)


func visit_grouping_expr(grouping: Grouping) -> void:
	resolve_expr(grouping.expression)


func visit_literal_expr(_literal: Literal) -> void:
	return


func visit_logical_expr(logical: Logical) -> void:
	resolve_expr(logical.left)
	resolve_expr(logical.right)


func visit_unary_expr(unary: Unary) -> void:
	resolve_expr(unary.right)




func visit_binary_expr(binary: Binary) -> void:
	resolve_expr(binary.left)
	resolve_expr(binary.right)


func visit_call_expr(expr: Call) -> void:
	resolve_expr(expr.callee)
	
	for arg in expr.arguments:
		resolve_expr(arg)



func begin_scope() -> void:
	scopes.push_back({})


func end_scope() -> void:
	scopes.pop_back()


func declare(token_name: Token) -> void:
	if scopes.is_empty():
		return
	
	var scope: Dictionary = scopes[-1]
	if scope.get(token_name.lexeme):
		Skyamn.error_token(token_name, "Already a variable with this name in this scope.")
	
	scope[token_name.lexeme] = false


func define(token_name: Token) -> void:
	if scopes.is_empty():
		return
	
	scopes[-1][token_name.lexeme] = true


func resolve(statements: Array[Stmt]) -> void:
	for stmt in statements:
		resolve_stmt(stmt)


func resolve_stmt(stmt: Stmt) -> void:
	stmt.accept(self)


func resolve_expr(expr: Expr) -> void:
	expr.accept(self)


func resolve_local(expr: Expr, token_name: Token) -> void:
	var index: int = scopes.size() - 1
	
	while index >= 0:
		if scopes[index].get(token_name.lexeme) != null:
			interpreter.resolve(expr, scopes.size() - 1 - index)
			return
		
		index -= 1


func resolve_function(function: SkyFunction, type: FunctionType) -> void:
	var enclosing_function: FunctionType = current_function
	current_function = type
	
	begin_scope()
	
	for param in function.params:
		declare(param)
		define(param)
	
	resolve(function.body)
	end_scope()
	
	current_function = enclosing_function
