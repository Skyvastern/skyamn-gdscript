extends SkyamnCallable
class_name SkyamnFunction

var declaration: SkyFunction


func _init(_declaration: SkyFunction) -> void:
	declaration = _declaration


func run(interpreter: Interpreter, arguments: Array[Variant]) -> Variant:
	var environment: SkyEnvironment = SkyEnvironment.new(interpreter.globals)
	
	for i in range(declaration.params.size()):
		environment.define(
			declaration.params[i].lexeme,
			arguments[i]
		)
	
	interpreter.execute_block(declaration.body, environment)
	
	if interpreter.return_value_set != null:
		var return_value: Variant = interpreter.return_value_set
		interpreter.return_value_set = null
		return return_value
	
	return null


func arity() -> int:
	return declaration.params.size()
