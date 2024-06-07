extends SkyamnCallable
class_name MathSqrt


func run(_interpreter: Interpreter, arguments: Array[Variant]) -> Variant:
	return sqrt(arguments[0])


func arity() -> int:
	return 1
