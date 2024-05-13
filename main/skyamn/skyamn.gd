extends RefCounted
class_name Skyamn

static var had_error: bool = false
static var had_runtime_error: bool = false


func _init() -> void:
	had_error = false
	had_runtime_error = false


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
	var statements: Array[Stmt] = parser.parse()
	
	# Stop if parse error(s) found
	if had_error:
		return
	
	var interpreter: Interpreter = Interpreter.new(
		_on_success,
		_on_runtime_error
	)
	
	var resolver: Resolver = Resolver.new(interpreter)
	resolver.resolve(statements)
	
	# Stop if resolution error(s) found
	if had_error:
		return
	
	interpreter.interpret(statements)


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


func _on_success(output: String) -> void:
	print(output)


func _on_runtime_error(token: Token, message: String) -> void:
	push_error("Runtime Error: %s\nAt line [%s]" % [message, token.line])
	had_runtime_error = true
