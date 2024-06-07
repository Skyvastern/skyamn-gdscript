extends SkyamnCallable
class_name MathDegToRad


func run(_interpreter: Interpreter, arguments: Array[Variant]) -> Variant:
	return deg_to_rad(arguments[0])


func arity() -> int:
	return 1
