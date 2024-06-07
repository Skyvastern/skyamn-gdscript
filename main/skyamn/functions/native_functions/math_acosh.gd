extends SkyamnCallable
class_name MathACosH


func run(_interpreter: Interpreter, arguments: Array[Variant]) -> Variant:
	return acosh(arguments[0])


func arity() -> int:
	return 1
