extends Control
class_name CodeEditor

@export_group("UI")
@export var code: TextEdit
@export var run_btn: Button
@export var output_label: Label
@export var error_label: Label

@export_group("References")
@export var taskbar_btn: TaskbarButton


func _ready() -> void:
	run_btn.pressed.connect(_on_run_btn_pressed)


func _on_run_btn_pressed() -> void:
	var source: String = code.text
	
	var skyamn: Skyamn = Skyamn.new()
	skyamn.run_source(source)
