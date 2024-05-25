extends TextureButton
class_name TaskbarButton

@export var window: Control
@export var window_scene: PackedScene
@export var window_container: Control


func _ready() -> void:
	pressed.connect(_on_pressed)
	_startup()


func _startup() -> void:
	if window == null or not is_instance_valid(window):
		visible = true
	elif not window.visible:
		visible = true
	else:
		visible = false


func _on_pressed() -> void:
	if window == null or not is_instance_valid(window):
		window = window_scene.instantiate()
		window.taskbar_btn = self
		window_container.add_child(window)
		visible = false
	
	elif not window.visible:
		window.visible = true
		visible = false
