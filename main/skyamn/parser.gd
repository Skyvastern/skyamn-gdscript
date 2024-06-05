extends RefCounted
class_name Parser

var tokens: Array[Token]
var current: int = 0
var indent_level: int = 0


func _init(_tokens: Array[Token]) -> void:
	tokens = _tokens


func parse() -> Array[Stmt]:
	var statements: Array[Stmt] = []
	
	while not is_at_end():
		var prev_current: int = current
		
		if not match_token_type([Token.TokenType.LINE_END]):
			statements.append(declaration())
		
		# In some situations, like if only ) is written, then an infinite loop occurs as current is not updated, because token EOF is never reached
		# Kinda hacky way to resolve this issue
		if current == prev_current:
			current += 1
	
	return statements


func declaration() -> Stmt:
	if match_token_type([Token.TokenType.FUN]):
		return function_declaration("function")
	
	if match_token_type([Token.TokenType.VAR]):
		return var_declaration()
	
	return statement()


func statement() -> Stmt:
	if match_token_type([Token.TokenType.IF]):
		return if_statement()
	
	if match_token_type([Token.TokenType.PRINT]):
		return print_statement()
	
	if match_token_type([Token.TokenType.RETURN]):
		return return_statement()
	
	if match_token_type([Token.TokenType.WHILE]):
		return while_statement()
	
	if peek().type == Token.TokenType.INDENT:
		return Block.new(block())
	
	return expression_statement()


func if_statement() -> Stmt:
	var conditional_branches: Array[Dictionary] = []
	
	# if branch
	var condition: Expr = expression()
	consume(Token.TokenType.LINE_END, "Expect 'line end' after if condition.")
	var if_branch: Array[Stmt] = block()
	
	conditional_branches.append({
		"condition": condition,
		"branch": if_branch
	})
	
	# elif branches
	while true:
		var elif_branch: Array[Stmt] = []
		if check_indentation_and_token(Token.TokenType.ELIF):
			var elif_condition: Expr = expression()
			consume(Token.TokenType.LINE_END, "Expect 'line end' after elif condition.")
			elif_branch = block()
			
			conditional_branches.append({
				"condition": elif_condition,
				"branch": elif_branch
			})
		else:
			break
	
	# else branch
	var else_branch: Array[Stmt] = []
	if check_indentation_and_token(Token.TokenType.ELSE):
		consume(Token.TokenType.LINE_END, "Expect 'line end' after else condition.")
		else_branch = block()
		
		conditional_branches.append({
			"condition": null,
			"branch": else_branch
		})
	
	# Return the final If statement
	return If.new(conditional_branches)


func print_statement() -> Stmt:
	var value: Expr = expression()
	consume(Token.TokenType.LINE_END, "Expect 'line end' after value.")
	return SkyPrint.new(value)


func return_statement() -> Stmt:
	var keyword: Token = previous()
	var value: Expr = null
	
	if not check(Token.TokenType.LINE_END):
		value = expression()
	
	consume(Token.TokenType.LINE_END, "Expect 'line end' after return value.")
	return Return.new(keyword, value)


func while_statement() -> Stmt:
	var condition: Expr = expression()
	consume(Token.TokenType.LINE_END, "Expect 'line end' after while condition.")
	var body: Array[Stmt] = block()
	
	return While.new(condition, body)


func expression_statement() -> Stmt:
	var expr: Expr = expression()
	consume(Token.TokenType.LINE_END, "Expect 'line end' after value.")
	return SkyExpression.new(expr)


func block() -> Array[Stmt]:
	var statements: Array[Stmt] = []
	indent_level += 1
	
	while not is_at_end() and check_indentation():
		if peek().type == Token.TokenType.LINE_END:
			advance()
		
		statements.append(declaration())
	
	indent_level -= 1
	return statements


func function_declaration(kind: String) -> SkyFunction:
	# Get function name
	var token_name: Token = consume(
		Token.TokenType.IDENTIFIER,
		"Expect %s name." % kind
	)
	
	# Get function parameters
	consume(
		Token.TokenType.LEFT_PAREN,
		"Expect '(' after %s name." % kind
	)
	
	var parameters: Array[Token] = []
	if not check(Token.TokenType.RIGHT_PAREN):
		if parameters.size() >= 255:
			Skyamn.error_token(peek(), "Can't have more than 255 parameters.")
		
		parameters.append(
			consume(Token.TokenType.IDENTIFIER, "Expect parameter name.")
		)
		
		while match_token_type([Token.TokenType.COMMA]):
			if parameters.size() >= 255:
				Skyamn.error_token(peek(), "Can't have more than 255 parameters.")
			
			parameters.append(
				consume(Token.TokenType.IDENTIFIER, "Expect parameter name.")
			)
	
	consume(Token.TokenType.RIGHT_PAREN, "Expect ')' after parameters.")
	
	# Get function body
	consume(Token.TokenType.LINE_END, "Expect 'line end' after %s signature." % kind)
	var body: Array[Stmt] = block()
	
	# Create and return the function node
	return SkyFunction.new(token_name, parameters, body)


func var_declaration() -> Stmt:
	var token_name: Token = consume(Token.TokenType.IDENTIFIER, "Expect variable name.")
	
	var initializer: Expr = null
	if match_token_type([Token.TokenType.EQUAL]):
		initializer = expression()
	
	consume(Token.TokenType.LINE_END, "Expect 'line end' after variable declaration.")
	return Var.new(token_name, initializer)



func expression() -> Expr:
	return assignment()


func assignment() -> Expr:
	var expr = or_operation()
	
	if match_token_type([Token.TokenType.EQUAL]):
		var equals: Token = previous()
		var value: Expr = assignment()
		
		if expr is Variable:
			var token_name: Token = expr.token_name
			return Assign.new(token_name, value)
		
		Skyamn.error_token(equals, "Invalid assignment target.")
	
	return expr


func or_operation() -> Expr:
	var expr: Expr = and_operation()
	
	while match_token_type([Token.TokenType.OR]):
		var operator: Token = previous()
		var right: Expr = and_operation()
		expr = Logical.new(expr, operator, right)
	
	return expr


func and_operation() -> Expr:
	var expr: Expr = equality()
	
	while match_token_type([Token.TokenType.AND]):
		var operator: Token = previous()
		var right: Expr = equality()
		expr = Logical.new(expr, operator, right)
	
	return expr


func equality() -> Expr:
	var expr: Expr = comparison()
	
	while match_token_type([
		Token.TokenType.BANG_EQUAL,
		Token.TokenType.EQUAL_EQUAL
	]):
		var operator: Token = previous()
		var right: Expr = comparison()
		expr = Binary.new(expr, operator, right)
	
	return expr


func comparison() -> Expr:
	var expr: Expr = term()
	
	while match_token_type([
		Token.TokenType.GREATER,
		Token.TokenType.GREATER_EQUAL,
		Token.TokenType.LESS,
		Token.TokenType.LESS_EQUAL
	]):
		var operator: Token = previous()
		var right: Expr = term()
		expr = Binary.new(expr, operator, right)
	
	return expr


func term() -> Expr:
	var expr: Expr = factor()
	
	while match_token_type([
		Token.TokenType.MINUS,
		Token.TokenType.PLUS
	]):
		var operator: Token = previous()
		var right: Expr = factor()
		expr = Binary.new(expr, operator, right)
	
	return expr


func factor() -> Expr:
	var expr: Expr = unary()
	
	while match_token_type([
		Token.TokenType.SLASH,
		Token.TokenType.STAR
	]):
		var operator: Token = previous()
		var right: Expr = unary()
		expr = Binary.new(expr, operator, right)
	
	return expr


func unary() -> Expr:
	if match_token_type([
		Token.TokenType.BANG,
		Token.TokenType.MINUS
	]):
		var operator: Token = previous()
		var right: Expr = unary()
		return Unary.new(operator, right)
	
	return function_call()


func function_call() -> Expr:
	var expr: Expr = primary()
	
	while true:
		if match_token_type([Token.TokenType.LEFT_PAREN]):
			expr = finish_function_call(expr)
		else:
			break
	
	return expr


func finish_function_call(callee: Expr) -> Expr:
	var arguments: Array[Expr] = []
	
	if not check(Token.TokenType.RIGHT_PAREN):
		if arguments.size() >= 255:
			Skyamn.error_token(peek(), "Can't have more than 255 arguments.")
		
		arguments.append(expression())
		
		while match_token_type([Token.TokenType.COMMA]):
			if arguments.size() >= 255:
				Skyamn.error_token(peek(), "Can't have more than 255 arguments.")
			
			arguments.append(expression())
	
	var paren: Token = consume(Token.TokenType.RIGHT_PAREN, "Expect ')' after arguments.")
	return Call.new(callee, paren, arguments)


func primary() -> Expr:
	if match_token_type([Token.TokenType.FALSE]):
		return Literal.new(false)
	
	if match_token_type([Token.TokenType.TRUE]):
		return Literal.new(true)
	
	if match_token_type([Token.TokenType.NULL]):
		return Literal.new(null)
	
	if match_token_type([
		Token.TokenType.NUMBER,
		Token.TokenType.STRING
	]):
		return Literal.new(previous().literal)
	
	if match_token_type([Token.TokenType.IDENTIFIER]):
		return Variable.new(previous())
	
	if match_token_type([Token.TokenType.LEFT_PAREN]):
		var expr: Expr = expression()
		consume(Token.TokenType.RIGHT_PAREN, "Expect ')' after expression.")
		return Grouping.new(expr)
	
	Skyamn.error_token(peek(), "Expected expression.")
	return null


func consume(type: Token.TokenType, message: String) -> Token:
	if check(type):
		return advance()
	
	Skyamn.error_token(peek(), message)
	return null


func synchronize() -> void:
	advance()
	
	while not is_at_end():
		if previous().type == Token.TokenType.LINE_END:
			return
		
		if peek().type == Token.TokenType.CLASS \
		or peek().type == Token.TokenType.FUN \
		or peek().type == Token.TokenType.VAR \
		or peek().type == Token.TokenType.IF \
		or peek().type == Token.TokenType.WHILE \
		or peek().type == Token.TokenType.PRINT \
		or peek().type == Token.TokenType.RETURN:
			return
		
		advance()


func match_token_type(types: Array[Token.TokenType]) -> bool:
	for type in types:
		if check(type):
			advance()
			return true
	
	return false


func check(type: Token.TokenType) -> bool:
	if is_at_end():
		return false
	
	return peek().type == type


func advance() -> Token:
	if not is_at_end():
		current += 1
	
	return previous()


# Checks if we have run out of tokens to parse
func is_at_end() -> bool:
	return peek().type == Token.TokenType.EOF


# Returns current token yet to be consumed
func peek() -> Token:
	return tokens[current]


# Returns the recently consumed token
func previous() -> Token:
	return tokens[current - 1]


# Checks indentation based on indent level
func check_indentation() -> bool:
	for i in range(indent_level):
		if tokens[current + i].type != Token.TokenType.INDENT:
			return false
	
	for i in range(indent_level):
		advance()
	
	return true


func check_indentation_and_token(token_type: Token.TokenType) -> bool:
	for i in range(indent_level):
		if tokens[current + i].type != Token.TokenType.INDENT:
			return false
	
	if tokens[current + indent_level].type != token_type:
		return false
	
	for i in range(indent_level + 1):
		advance()
	
	return true
