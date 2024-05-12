extends SkyamnCallable
class_name Clock


func run(_interpreter: Interpreter, _arguments: Array[Variant]) -> Variant:
	return Time.get_unix_time_from_system()


func arity() -> int:
	return 0
