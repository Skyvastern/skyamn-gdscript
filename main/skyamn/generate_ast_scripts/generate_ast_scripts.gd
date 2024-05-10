@tool
extends Node
class_name GenerateASTScripts

const BASE_PATH: String = "res://main/skyamn/generate_ast_scripts/scripts/"


@export var run: bool = false:
	set(value):
		run = value
		if run:
			generate()


func generate() -> void:
	define_ast(
		"expr",
		[
			"assign = token_name: Token, value: Expr",
			"binary = left: Expr, operator: Token, right: Expr",
			"grouping = expression: Expr",
			"literal = value: Variant",
			"unary = operator: Token, right: Expr",
			"variable = token_name: Token"
		]
	)
	
	define_ast(
		"stmt",
		[
			"sky_expression = expr: Expr",
			"sky_print = expr: Expr",
			"var = token_name: Token, initializer: Expr"
		]
	)


func _create_dir_and_overwrite(dir_path: String) -> void:
	if DirAccess.dir_exists_absolute(dir_path):
		# Remove directory contents (won't remove directory itself)
		for file in DirAccess.get_files_at(dir_path):
			DirAccess.remove_absolute(dir_path + file)
	
	# Create directory
	DirAccess.make_dir_absolute(dir_path)


func define_ast(main_script_name: String, types: Array[String]) -> void:
	var dir_path: String = BASE_PATH + main_script_name + "/"
	var main_script_path: String = dir_path + main_script_name + ".gd"
	
	_create_dir_and_overwrite(dir_path)
	
	# Create the main script file
	var file: FileAccess = FileAccess.open(main_script_path, FileAccess.WRITE)
	
	var content: String = ""
	
	content += "extends RefCounted"
	content += "\n"
	content += "class_name " + main_script_name.to_pascal_case()
	content += "\n\n"
	
	content += "func accept(_visitor: BaseVisitor):\n"
	content += "\treturn\n"
	
	file.store_string(content)
	
	# Create visitor script
	define_visitor(dir_path, main_script_name, types)
	
	# Create derived scripts
	var types_dir_path: String = dir_path + "types/"
	_create_dir_and_overwrite(types_dir_path)
	
	for t in types:
		var script_name: String = t.split("=")[0].strip_edges()
		
		var variables: String = t.split("=")[1].strip_edges()
		var var_data: Array = []
		
		for v in variables.split(","):
			var var_name: String = v.strip_edges().split(":")[0]
			var var_type: String = v.strip_edges().split(":")[1].strip_edges()
			var_data.append([var_name, var_type])
		
		define_type(types_dir_path, main_script_name, script_name, var_data)


func define_type(dir_path: String, parent_script_name: String, script_name: String, var_data: Array) -> void:
	# Create the file
	var script_path: String = dir_path + script_name + ".gd"
	var file: FileAccess = FileAccess.open(script_path, FileAccess.WRITE)
	
	# Write class it extends, and its own class name
	var content: String = ""
	content += "extends " + parent_script_name.to_pascal_case() + "\n"
	content += "class_name " + script_name.to_pascal_case() + "\n"
	content += "\n"
	
	# Write down variables
	for v in var_data:
		content += "var %s: %s" % [v[0], v[1]]
		content += "\n"
	
	# Write _init() function signature
	content += "\n\n"
	content += "func _init("
	
	for i in range(var_data.size()):
		content += "_%s: %s" % [var_data[i][0], var_data[i][1]]
		if i < var_data.size() - 1:
			content += ", "
	
	content += ") -> void:"
	content += "\n"
	
	# Write _init() function contents
	for v in var_data:
		content += "\t"
		content += "%s = _%s" % [v[0], v[0]]
		content += "\n"
	
	# Write accept() method
	content += "\n"
	content += "func accept(visitor: BaseVisitor):\n"
	content += "\treturn visitor.visit_%s_%s(self)\n" % [script_name, parent_script_name]
	
	# Save the file
	file.store_string(content)


func define_visitor(dir_path: String, parent_script_name: String, types: Array) -> void:
	# Create the file
	var script_name: String = parent_script_name + "_visitor"
	var script_path: String = dir_path + script_name + ".gd"
	var file: FileAccess = FileAccess.open(script_path, FileAccess.WRITE)
	
	# Write class it extends, and its own class name
	var content: String = ""
	content += "extends BaseVisitor" + "\n"
	content += "class_name " + script_name.to_pascal_case() + "\n"
	content += "\n"
	
	# Write functions
	for t in types:
		var t_name: String = t.split("=")[0].strip_edges()
		var fun_name: String = "visit_%s_%s" % [t_name, parent_script_name]
		
		content += "\n"
		content += "func %s(_%s: %s):\n" % [fun_name, t_name, t_name.to_pascal_case()]
		content += "\tpass\n"
	
	# Save the file
	file.store_string(content)
