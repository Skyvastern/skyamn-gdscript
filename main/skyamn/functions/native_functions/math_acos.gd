extends SkyamnCallable
class_name MathACos


func run(_interpreter: Interpreter, arguments: Array[Variant]) -> Variant:
	return acos(arguments[0])


func arity() -> int:
	return 1
