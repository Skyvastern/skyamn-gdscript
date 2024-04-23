extends Node
class_name Token

static var count: int = 0

@export var type: TokenType
@export var lexeme: String
@export var literal: String
@export var line: int


func setup(_type: TokenType, _lexeme: String, _literal: String, _line: int) -> void:
	type = _type
	lexeme = _lexeme
	literal = _literal
	line = _line
	
	# For visual feedback in Godot Editor
	name = str(count) + " - " + TokenType.keys()[type]
	count += 1
	
	print("\n" + str(count) + "\n" + _to_string())


func _to_string() -> String:
	return "Type: " + TokenType.keys()[type] + "\nLexeme: " + lexeme + "\nLiteral: " + literal


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
