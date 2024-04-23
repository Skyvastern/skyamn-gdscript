extends Node
class_name Main

@export_group("Main")
@export var interpreter: Interpreter

@export_group("UI")
@export var code: TextEdit
@export var run_btn: Button
@export var output: Label


func _ready() -> void:
	run_btn.pressed.connect(_on_run_btn_pressed)


func _on_run_btn_pressed() -> void:
	var source: String = code.text
	interpreter.run_source(source)
