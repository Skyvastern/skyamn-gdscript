extends SkyamnCallable
class_name MathTan


func run(_interpreter: Interpreter, arguments: Array[Variant]) -> Variant:
	return tan(arguments[0])


func arity() -> int:
	return 1
