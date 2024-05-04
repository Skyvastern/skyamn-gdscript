extends RefCounted
class_name Token

var type: TokenType
var lexeme: String
var literal: Variant
var line: int


func _init(_type: TokenType, _lexeme: String, _literal: Variant, _line: int) -> void:
	type = _type
	lexeme = _lexeme
	literal = _literal
	line = _line


func _to_string() -> String:
	return "Type: " + TokenType.keys()[type] + "\nLexeme: " + lexeme + "\nLiteral: " + str(literal)


enum TokenType {
	# Single character tokens
	LEFT_PAREN, RIGHT_PAREN, LEFT_BRACE, RIGHT_BRACE,
	COMMA, DOT, MINUS, PLUS, SEMICOLON, SLASH, STAR,
	
	# One or two characters token
	BANG, BANG_EQUAL,
	EQUAL, EQUAL_EQUAL,
	GREATER, GREATER_EQUAL,
	LESS, LESS_EQUAL,
	
	# Literals
	IDENTIFIER, STRING, NUMBER,
	
	# Keywords
	AND, CLASS, ELSE, FALSE, FUN, FOR, IF, NULL, OR,
	PRINT, RETURN, SUPER, THIS, TRUE, VAR, WHILE,
	
	EOF
}


static var keywords: Dictionary = {
	"and": TokenType.AND,
	"class": TokenType.CLASS,
	"else": TokenType.ELSE,
	"false": TokenType.FALSE,
	"fun": TokenType.FUN,
	"for": TokenType.FOR,
	"if": TokenType.IF,
	"null": TokenType.NULL,
	"or": TokenType.OR,
	"print": TokenType.PRINT,
	"return": TokenType.RETURN,
	"super": TokenType.SUPER,
	"this": TokenType.THIS,
	"true": TokenType.TRUE,
	"var": TokenType.VAR,
	"while": TokenType.WHILE
}
