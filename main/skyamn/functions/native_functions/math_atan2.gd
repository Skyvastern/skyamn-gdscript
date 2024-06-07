extends SkyamnCallable
class_name MathATan2


func run(_interpreter: Interpreter, arguments: Array[Variant]) -> Variant:
	return atan2(arguments[0], arguments[1])


func arity() -> int:
	return 2
