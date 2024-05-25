extends Control
class_name CodeEditor

@export_group("UI")
@export var code: TextEdit
@export var run_btn: Button
@export var output_label: Label
@export var errors_label: Label
@export var tabs_container: TabContainer

@export_group("References")
@export var taskbar_btn: TaskbarButton


func _ready() -> void:
	run_btn.pressed.connect(_on_run_btn_pressed)
	code.text_changed.connect(_on_code_text_changed)
	
	_setup()


func _setup() -> void:
	# Set gutter for line numbers
	code.add_gutter(0)
	code.set_gutter_width(0, 50)
	
	# Add line 1
	code.set_line_gutter_text(0, 0, "1")
	
	# Set focus
	code.grab_focus()


func _on_run_btn_pressed() -> void:
	# Clear output and errors log
	output_label.text = ""
	errors_label.text = ""
	
	# Run the program
	var source: String = code.text
	
	var skyamn: Skyamn = Skyamn.new()
	skyamn.result_log_message.connect(_on_result_log_message)
	skyamn.result_runtime_error.connect(_on_result_runtime_error)
	
	skyamn.run_source(source)


func _on_result_log_message(message: String) -> void:
	output_label.text += message + "\n"
	
	# Only switch to output tab if there are no errors
	if errors_label.text == "":
		tabs_container.current_tab = 0


func _on_result_runtime_error(error_message: String) -> void:
	errors_label.text += error_message + "\n\n"
	
	# Switch to errors tab
	tabs_container.current_tab = 1


func _on_code_text_changed() -> void:
	var lines: int = code.get_line_count()
	
	for i in range(lines):
		code.set_line_gutter_text(i, 0, str(i + 1))
		code.set_line_gutter_item_color(i, 0, Color.GRAY)
