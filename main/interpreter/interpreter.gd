extends RefCounted
class_name Interpreter

static var had_error: bool = false


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
	
	for t in tokens:
		print(t)
		print("\n")


static func error(line: int, message: String) -> void:
	report(line, "", message)


static func report(line: int, where: String, message: String) -> void:
	push_error("[line " + str(line) + "] Error" + where + ": " + message)
	had_error = true


static func substring(value: String, start_index: int, end_index: int) -> String:
	var trimmed_value: String = ""
	
	for i in range(start_index, end_index):
		trimmed_value += value[i]
	
	return trimmed_value
