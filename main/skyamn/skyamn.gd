extends RefCounted
class_name Skyamn

static var had_error: bool = false
static var had_runtime_error: bool = false
static var syntax_errors: Array[String] = []

signal result_log_message
signal result_syntax_error
signal result_runtime_error


func _init() -> void:
	had_error = false
	had_runtime_error = false
	syntax_errors.clear()


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
	source += "\n"
	
	var scanner: Scanner = Scanner.new(source)
	var tokens: Array[Token] = scanner.scan_tokens()
	
	var parser: Parser = Parser.new(tokens)
	var statements: Array[Stmt] = parser.parse()
	
	if had_error:
		result_syntax_error.emit(syntax_errors)
		return
	
	var interpreter: Interpreter = Interpreter.new(
		_on_log_message,
		_on_runtime_error
	)
	
	interpreter.interpret(statements)


func check_syntax_errors(source: String) -> void:
	source += "\n"
	
	var scanner: Scanner = Scanner.new(source)
	var tokens: Array[Token] = scanner.scan_tokens()
	
	var parser: Parser = Parser.new(tokens)
	parser.parse()
	
	if had_error:
		result_syntax_error.emit(syntax_errors)
		return


static func error(line: int, message: String) -> void:
	report(line, "", message)


static func error_token(token: Token, message: String) -> void:
	if token.type == Token.TokenType.EOF:
		report(token.line, " at end", message)
	else:
		report(token.line, " at '" + Token.get_printable_lexeme(token.lexeme) + "'", message)


static func report(line: int, where: String, message: String) -> void:
	var error_message: String = "[line " + str(line) + "] Error" + where + ": " + message
	syntax_errors.append(error_message)
	had_error = true


static func substring(value: String, start_index: int, end_index: int) -> String:
	var trimmed_value: String = ""
	
	for i in range(start_index, end_index):
		trimmed_value += value[i]
	
	return trimmed_value


func _on_log_message(message: String) -> void:
	result_log_message.emit(message)


func _on_runtime_error(token: Token, message: String) -> void:
	result_runtime_error.emit("Runtime Error: %s\nAt line [%s]" % [message, token.line])
	had_runtime_error = true
