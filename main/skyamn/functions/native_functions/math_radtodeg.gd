extends SkyamnCallable
class_name MathRadToDeg


func run(_interpreter: Interpreter, arguments: Array[Variant]) -> Variant:
	return rad_to_deg(arguments[0])


func arity() -> int:
	return 1
