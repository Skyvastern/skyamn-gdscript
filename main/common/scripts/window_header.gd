extends Control
class_name WindowHeader

@export_group("UI")
@export var close_btn: TextureButton
@export var maximize_btn: TextureButton
@export var minimize_btn: TextureButton

@export_group("References")
@export var main_window: Control

var is_maximized: bool = false

var last_anchor_left: float
var last_anchor_top: float
var last_anchor_right: float
var last_anchor_bottom: float

var last_offset_left: float
var last_offset_top: float
var last_offset_right: float
var last_offset_bottom: float

var last_grow_horizontal: Control.GrowDirection
var last_grow_vertical: Control.GrowDirection


func _ready() -> void:
	close_btn.pressed.connect(_on_close_btn_pressed)
	maximize_btn.pressed.connect(_on_maximize_btn_pressed)
	minimize_btn.pressed.connect(_on_minimize_btn_pressed)


func _on_close_btn_pressed() -> void:
	main_window.taskbar_btn.visible = true
	main_window.queue_free()


func _on_maximize_btn_pressed() -> void:
	is_maximized = !is_maximized
	
	if is_maximized:
		_save_window_values()
		_maximize_window()
	else:
		_reset_window()


func _maximize_window() -> void:
	# Set values to cover full screen
	main_window.anchor_left = 0
	main_window.anchor_top = 0
	main_window.anchor_right = 1
	main_window.anchor_bottom = 1
	
	main_window.offset_left = 0
	main_window.offset_top = 0
	main_window.offset_right = 0
	main_window.offset_bottom = 0
	
	main_window.grow_horizontal = Control.GROW_DIRECTION_BOTH
	main_window.grow_vertical = Control.GROW_DIRECTION_BOTH


func _reset_window() -> void:
	main_window.anchor_left = last_anchor_left
	main_window.anchor_top = last_anchor_top
	main_window.anchor_right = last_anchor_right
	main_window.anchor_bottom = last_anchor_bottom
	
	main_window.offset_left = last_offset_left
	main_window.offset_top = last_offset_top
	main_window.offset_right = last_offset_right
	main_window.offset_bottom = last_offset_bottom
	
	main_window.grow_horizontal = last_grow_horizontal
	main_window.grow_vertical = last_grow_vertical


func _save_window_values() -> void:
	last_anchor_left = main_window.anchor_left
	last_anchor_top = main_window.anchor_top
	last_anchor_right = main_window.anchor_right
	last_anchor_bottom = main_window.anchor_bottom
	
	last_offset_left = main_window.offset_left
	last_offset_top = main_window.offset_top
	last_offset_right = main_window.offset_right
	last_offset_bottom = main_window.offset_bottom
	
	last_grow_horizontal = main_window.grow_horizontal
	last_grow_vertical = main_window.grow_vertical


func _on_minimize_btn_pressed() -> void:
	main_window.taskbar_btn.visible = true
	main_window.visible = false
