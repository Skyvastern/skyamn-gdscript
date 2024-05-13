extends RefCounted
class_name SkyEnvironment

var values: Dictionary = {}
var enclosing: SkyEnvironment


func _init(_enclosing: SkyEnvironment = null) -> void:
	enclosing = _enclosing


func define(var_name: String, value: Variant) -> void:
	values[var_name] = value


func ancestor(distance: int) -> SkyEnvironment:
	var environment: SkyEnvironment = self
	
	for i in range(distance):
		environment = environment.enclosing
	
	return environment


func get_at(distance: int, name: String) -> Variant:
	return ancestor(distance).values.get(name)


func get_value(token_name: Token) -> Variant:
	if values.get(token_name.lexeme) != null:
		return values[token_name.lexeme]
	
	if enclosing != null:
		return enclosing.get_value(token_name)
	
	return null


func assign_at(distance: int, token_name: Token, value: Variant) -> void:
	ancestor(distance).values[token_name.lexeme] = value


func assign(token_name: Token, value: Variant) -> bool:
	if values.get(token_name.lexeme) != null:
		values[token_name.lexeme] = value
		return true
	
	if enclosing != null:
		return enclosing.assign(token_name, value)
	
	return false
