extends RefCounted
class_name Parser

var tokens: Array[Token]
var current: int = 0


func _init(_tokens: Array[Token]) -> void:
	tokens = _tokens


func parse() -> Expr:
	return expression()


func expression() -> Expr:
	return equality()


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
	
	return primary()


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
	
	if match_token_type([Token.TokenType.LEFT_PAREN]):
		var expr: Expr = expression()
		consume(Token.TokenType.RIGHT_PAREN, "Expect ')' after expression.")
		return Grouping.new(expr)
	
	Interpreter.error_token(peek(), "Expected expression.")
	return null


func consume(type: Token.TokenType, message: String) -> Token:
	if check(type):
		return advance()
	
	Interpreter.error_token(peek(), message)
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
