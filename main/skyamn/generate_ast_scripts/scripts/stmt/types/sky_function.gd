extends Stmt
class_name SkyFunction

var token_name: Token
var params: Array[Token]
var body: Array[Stmt]


func _init(_token_name: Token, _params: Array[Token], _body: Array[Stmt]) -> void:
	token_name = _token_name
	params = _params
	body = _body

func accept(visitor: BaseVisitor):
	return visitor.visit_sky_function_stmt(self)
