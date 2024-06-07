extends SkyamnCallable
class_name MathCos


func run(_interpreter: Interpreter, arguments: Array[Variant]) -> Variant:
	return cos(arguments[0])


func arity() -> int:
	return 1
