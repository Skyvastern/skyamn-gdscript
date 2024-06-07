extends SkyamnCallable
class_name MathPower


func run(_interpreter: Interpreter, arguments: Array[Variant]) -> Variant:
	return pow(arguments[0], arguments[1])


func arity() -> int:
	return 2
