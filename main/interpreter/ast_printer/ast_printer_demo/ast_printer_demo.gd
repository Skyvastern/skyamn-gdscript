extends Node


func _ready() -> void:
	# Create a binary expression
	var expression: Binary = Binary.new(
		Unary.new(
			Token.new(Token.TokenType.MINUS, "-", null, 1),
			Literal.new("123")
		),
		
		Token.new(Token.TokenType.STAR, "*", null, 1),
		
		Grouping.new(
			Literal.new("45.67")
		)
	)
	
	# Print
	var ast_printer: ASTPrinter = ASTPrinter.new()
	var output: String = ast_printer.print_pretty(expression)
	print("Output: ", output)
