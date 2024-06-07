extends SkyamnCallable
class_name MathASin


func run(_interpreter: Interpreter, arguments: Array[Variant]) -> Variant:
	return asin(arguments[0])


func arity() -> int:
	return 1
