extends ScrollContainer
class_name SyntaxErrorFooter

@export var error_message: Label


func setup(message) -> void:
	error_message.text = message
