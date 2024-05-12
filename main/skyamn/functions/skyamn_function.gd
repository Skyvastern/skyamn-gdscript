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
	return null


func arity() -> int:
	return declaration.params.size()
