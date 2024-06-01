extends Node

@export var text_edit: TextEdit
@export var run_btn: Button


func _ready() -> void:
	run_btn.pressed.connect(_on_run_btn_pressed)


func _on_run_btn_pressed() -> void:
	var source: String = text_edit.text
	
	var skyamn: Skyamn = Skyamn.new()
	skyamn.result_log_message.connect(_on_result_log_message)
	skyamn.result_syntax_error.connect(_on_result_syntax_error)
	skyamn.result_runtime_error.connect(_on_result_runtime_error)
	
	skyamn.run_source(source)



func _on_result_log_message(message: String) -> void:
	print(message)


func _on_result_syntax_error(syntax_errors: Array[String]) -> void:
	var error_message: String = syntax_errors[0]
	push_error("Syntax Error: ", error_message)


func _on_result_runtime_error(error_message: String) -> void:
	var message: String = error_message + "\n\n"
	push_error("Runtime Error: ", message)
