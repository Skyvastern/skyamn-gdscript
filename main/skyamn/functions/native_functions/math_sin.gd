extends SkyamnCallable
class_name MathSin


func run(_interpreter: Interpreter, arguments: Array[Variant]) -> Variant:
	return sin(arguments[0])


func arity() -> int:
	return 1
