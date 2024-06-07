extends SkyamnCallable
class_name MathAbs


func run(_interpreter: Interpreter, arguments: Array[Variant]) -> Variant:
	return abs(arguments[0])


func arity() -> int:
	return 1
