extends Node
class_name SkyEnvironment

var values: Dictionary = {}


func define(var_name: String, value: Variant) -> void:
	values[var_name] = value


func get_value(token_name: Token) -> Variant:
	if values.get(token_name.lexeme):
		return values[token_name.lexeme]
	
	return null
