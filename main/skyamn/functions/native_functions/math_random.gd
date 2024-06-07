extends SkyamnCallable
class_name MathRandom


func run(_interpreter: Interpreter, arguments: Array[Variant]) -> Variant:
	return randf_range(arguments[0], arguments[1])


func arity() -> int:
	return 2
