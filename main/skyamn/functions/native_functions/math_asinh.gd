extends SkyamnCallable
class_name MathASinH


func run(_interpreter: Interpreter, arguments: Array[Variant]) -> Variant:
	return asinh(arguments[0])


func arity() -> int:
	return 1
