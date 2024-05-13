extends RefCounted
class_name Parser

var tokens: Array[Token]
var current: int = 0


func _init(_tokens: Array[Token]) -> void:
	tokens = _tokens


func parse() -> Array[Stmt]:
	var statements: Array[Stmt] = []
	
	while not is_at_end():
		statements.append(declaration())
	
	return statements


func declaration() -> Stmt:
	if match_token_type([Token.TokenType.FUN]):
		return function_declaration("function")
	
	if match_token_type([Token.TokenType.VAR]):
		return var_declaration()
	
	return statement()


func statement() -> Stmt:
	if match_token_type([Token.TokenType.FOR]):
		return for_statement()
	
	if match_token_type([Token.TokenType.IF]):
		return if_statement()
	
	if match_token_type([Token.TokenType.PRINT]):
		return print_statement()
	
	if match_token_type([Token.TokenType.RETURN]):
		return return_statement()
	
	if match_token_type([Token.TokenType.WHILE]):
		return while_statement()
	
	if match_token_type([Token.TokenType.LEFT_BRACE]):
		return Block.new(block())
	
	return expression_statement()


func for_statement() -> Stmt:
	consume(Token.TokenType.LEFT_PAREN, "Expect '(' after 'for'.")
	
	# Get initializer statement
	var initializer: Stmt
	
	if match_token_type([Token.TokenType.SEMICOLON]):
		initializer = null
	elif match_token_type([Token.TokenType.VAR]):
		initializer = var_declaration()
	else:
		initializer = expression_statement()
	
	# Get conditional expressional
	var condition: Expr = null
	
	if not check(Token.TokenType.SEMICOLON):
		condition = expression()
	
	consume(Token.TokenType.SEMICOLON, "Expect ';' after loop condition.")
	
	# Get increment expression
	var increment: Expr = null
	if not check(Token.TokenType.RIGHT_PAREN):
		increment = expression()
	
	consume(Token.TokenType.RIGHT_PAREN, "Expect ')' after for clauses.")
	
	# Get the body
	var body: Stmt = statement()
	
	# Desugar for loop to a while loop
	if increment != null:
		body = Block.new([
			body,
			SkyExpression.new(increment)
		])
	
	if condition == null:
		condition = Literal.new(true)
	
	body = While.new(condition, body)
	
	if initializer != null:
		body = Block.new([
			initializer,
			body
		])
	
	return body


func if_statement() -> Stmt:
	consume(Token.TokenType.LEFT_PAREN, "Expect '(' after if.")
	var condition: Expr = expression()
	consume(Token.TokenType.RIGHT_PAREN, "Expect ')' after if condition.")
	
	var then_branch: Stmt = statement()
	
	var else_branch: Stmt = null
	if match_token_type([Token.TokenType.ELSE]):
		else_branch = statement()
	
	return If.new(condition, then_branch, else_branch)


func print_statement() -> Stmt:
	var value: Expr = expression()
	consume(Token.TokenType.SEMICOLON, "Expect ';' after value.")
	return SkyPrint.new(value)


func return_statement() -> Stmt:
	var keyword: Token = previous()
	var value: Expr = null
	
	if not check(Token.TokenType.SEMICOLON):
		value = expression()
	
	consume(Token.TokenType.SEMICOLON, "Expect ';' after return value.")
	return Return.new(keyword, value)


func while_statement() -> Stmt:
	consume(Token.TokenType.LEFT_PAREN, "Expect '(' after 'while'.")
	var condition: Expr = expression()
	consume(Token.TokenType.RIGHT_PAREN, "Expect ')' after condition.")
	var body: Stmt = statement()
	
	return While.new(condition, body)


func expression_statement() -> Stmt:
	var expr: Expr = expression()
	consume(Token.TokenType.SEMICOLON, "Expect ';' after value.")
	return SkyExpression.new(expr)


func block() -> Array[Stmt]:
	var statements: Array[Stmt] = []
	
	while not check(Token.TokenType.RIGHT_BRACE) and not is_at_end():
		statements.append(declaration())
	
	consume(Token.TokenType.RIGHT_BRACE, "Expect '}' after block.")
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
	consume(Token.TokenType.LEFT_BRACE, "Expect '{' before %s body." % kind)
	var body: Array[Stmt] = block()
	
	# Create and return the function node
	return SkyFunction.new(token_name, parameters, body)


func var_declaration() -> Stmt:
	var token_name: Token = consume(Token.TokenType.IDENTIFIER, "Expect variable name.")
	
	var initializer: Expr = null
	if match_token_type([Token.TokenType.EQUAL]):
		initializer = expression()
	
	consume(Token.TokenType.SEMICOLON, "Expect ';' after variable declaration.")
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
		if previous().type == Token.TokenType.SEMICOLON:
			return
		
		if peek().type == Token.TokenType.CLASS \
		or peek().type == Token.TokenType.FUN \
		or peek().type == Token.TokenType.VAR \
		or peek().type == Token.TokenType.FOR \
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
