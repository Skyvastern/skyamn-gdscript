extends RefCounted
class_name Scanner

var source: String
var tokens: Array[Token]

var start: int = 0
var current: int = 0
var line: int = 1


func _init(_source: String) -> void:
	source = _source
	tokens = []


func scan_tokens() -> Array[Token]:
	while not is_at_end():
		start = current
		scan_a_token()
	
	var token: Token = Token.new(Token.TokenType.EOF, "", null, line)
	tokens.append(token)
	
	return tokens


func scan_a_token() -> void:
	var c: String = advance()
	match c:
		"(":
			add_token(Token.TokenType.LEFT_PAREN)
		")":
			add_token(Token.TokenType.RIGHT_PAREN)
		"\t":
			add_token(Token.TokenType.INDENT)
		".":
			add_token(Token.TokenType.DOT)
		",":
			add_token(Token.TokenType.COMMA)
		"+":
			add_token(Token.TokenType.PLUS)
		"-":
			add_token(Token.TokenType.MINUS)
		"\n":
			add_token(Token.TokenType.LINE_END)
			line += 1
		"*":
			add_token(Token.TokenType.STAR)
		"%":
			add_token(Token.TokenType.PERCENT)
		"!":
			if match_char("="):
				add_token(Token.TokenType.BANG_EQUAL)
			else:
				add_token(Token.TokenType.BANG)
		"=":
			if match_char("="):
				add_token(Token.TokenType.EQUAL_EQUAL)
			else:
				add_token(Token.TokenType.EQUAL)
		"<":
			if match_char("="):
				add_token(Token.TokenType.LESS_EQUAL)
			else:
				add_token(Token.TokenType.LESS)
		">":
			if match_char("="):
				add_token(Token.TokenType.GREATER_EQUAL)
			else:
				add_token(Token.TokenType.GREATER)
		"/":
			if match_char("/"):
				while peek() != "\n" and not is_at_end():
					advance()
			else:
				add_token(Token.TokenType.SLASH)
		" ", "\r":
			pass
		'"':
			string()
		_:
			if is_digit(c):
				number()
			elif is_alpha(c):
				identifier()
			else:
				Skyamn.error(line, "Unexpected character: " + c)


func is_at_end() -> bool:
	return current >= source.length()


func advance() -> String:
	var next_char: String = source[current]
	current += 1
	return next_char


func add_token(type: Token.TokenType) -> void:
	add_token_literal(type, null)


func add_token_literal(type: Token.TokenType, literal: Variant) -> void:
	var text: String = Skyamn.substring(source, start, current)
	
	tokens.append(
		Token.new(type, text, literal, line)
	)


func match_char(expected: String) -> bool:
	if is_at_end():
		return false
	
	if source[current] != expected:
		return false
	
	current += 1
	return true


func peek() -> String:
	if is_at_end():
		return ""
	
	return source[current]


func string() -> void:
	while peek() != '"' and not is_at_end():
		if peek() == "\n":
			line += 1
		
		advance()
	
	if is_at_end():
		Skyamn.error(line, "Unterminated string.")
		return
	
	advance()
	
	var value: String = Skyamn.substring(source, start + 1, current - 1)
	add_token_literal(Token.TokenType.STRING, value)


func is_digit(c: String) -> bool:
	return c >= "0" and c <= "9"


func peek_next() -> String:
	if (current + 1) >= source.length():
		return ""
	
	return source[current + 1]


func number() -> void:
	while is_digit(peek()):
		advance()
	
	# Look for fractional part
	if peek() == "." and is_digit(peek_next()):
		advance()
		
		while is_digit(peek()):
			advance()
	
	add_token_literal(
		Token.TokenType.NUMBER,
		float(Skyamn.substring(source, start, current))
	)


func is_alpha(c: String) -> bool:
	return (c >= "a" and c <= "z") or (c >= "A" and c <= "Z") or c == "_"


func is_alpha_numeric(c: String) -> bool:
	return is_alpha(c) or is_digit(c)


func identifier() -> void:
	while is_alpha_numeric(peek()):
		advance()
	
	var text: String = Skyamn.substring(source, start, current)
	var type = Token.keywords.get(text)
	if type == null:
		type = Token.TokenType.IDENTIFIER
	
	add_token(type)
