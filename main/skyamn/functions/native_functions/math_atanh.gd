extends SkyamnCallable
class_name MathATanH


func run(_interpreter: Interpreter, arguments: Array[Variant]) -> Variant:
	return atanh(arguments[0])


func arity() -> int:
	return 1
