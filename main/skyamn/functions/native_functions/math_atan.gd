extends SkyamnCallable
class_name MathATan


func run(_interpreter: Interpreter, arguments: Array[Variant]) -> Variant:
	return atan(arguments[0])


func arity() -> int:
	return 1
