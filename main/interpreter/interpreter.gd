extends RefCounted
class_name Interpreter

static var had_error: bool = false


func _init() -> void:
	had_error = false


func start(source: String) -> bool:
	if source == "":
		print("Source code is empty.")
	else:
		run_source(source)
	
	if had_error:
		return false
	
	return true


func run_source(source: String) -> void:
	_run(source)


func run_prompt() -> void:
	return


func _run(source: String) -> void:
	var scanner: Scanner = Scanner.new(source)
	var tokens: Array[Token] = scanner.scan_tokens()
	
	var parser: Parser = Parser.new(tokens)
	var expression: Expr = parser.parse()
	
	if had_error:
		return
	
	var ast_printer: ASTPrinter = ASTPrinter.new()
	var output: String = ast_printer.print_pretty(expression)
	print(output)


static func error(line: int, message: String) -> void:
	report(line, "", message)


static func error_token(token: Token, message: String) -> void:
	if token.type == Token.TokenType.EOF:
		report(token.line, " at end", message)
	else:
		report(token.line, " at '" + token.lexeme + "'", message)


static func report(line: int, where: String, message: String) -> void:
	push_error("[line " + str(line) + "] Error" + where + ": " + message)
	had_error = true


static func substring(value: String, start_index: int, end_index: int) -> String:
	var trimmed_value: String = ""
	
	for i in range(start_index, end_index):
		trimmed_value += value[i]
	
	return trimmed_value
