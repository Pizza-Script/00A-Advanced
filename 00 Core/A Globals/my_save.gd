# class_name MySave																# all about save file
extends Node

"""
func _save() -> void:
	var vars: Dictionary = {													# vars to save
		_vars = _vars,															# "_vars" = _vars (lua syntax)
	}																			# prevents misspelling

	if MySave.init(self, vars) == false:										# load data once
		_set_data(_vars)														# use loaded data

	MySave.save(self, vars)
"""

var save_data: Dictionary[String, String]										# node.name as Key


func _ready() -> void:
	_load()


func _load() -> void:															# NOTE: LOAD FILE TO DICTIONARY
	var save_path: String = "user://data.save"
	if FileAccess.file_exists(save_path) == false:								# file not found
		return

	var save_file: FileAccess = FileAccess.open(save_path, FileAccess.READ)
	var save_text: String = save_file.get_as_text()
	if save_text.is_empty():													# file empty
		return

	var json_load = JSON.parse_string(save_text)
	if json_load == null:														# invalid JSON
		print("JSON Parse Error: ", json_load.get_error_message(), " in ",
		save_file.get_as_text(), " at line ", json_load.get_error_line())
		return

	var json_data: Dictionary = json_load
	for json_keys in json_data:
		save_data[json_keys] = str(json_data[json_keys])


func init(node: Node, vars: Dictionary) -> bool:								# NOTE: DICTIONARY TO NODE VARS
	var node_name: String = node.name

	if save_data.has(node_name) == true:										# only load once
		return true

	if save_data.has(node_name) == false \
	|| save_data[node_name].is_empty() == true:									# no save data
		return true

	var json_load = JSON.parse_string(save_data[node_name])
	if json_load == null:														# invalid JSON
		print("JSON Parse Error: ", json_load.get_error_message(), " in ",
		save_data, " at line ", json_load.get_error_line())
		return true

	var json_data: Dictionary = json_load										# load data into node vars
	for property in node.get_property_list():
		var var_name: String = str(property["name"])
		if vars.has(var_name) && json_data.has(var_name):
			node.set(var_name, str_to_var(str(json_data[var_name])))

	return false


func save(node: Node, vars: Dictionary) -> void:
	var node_name: String = node.name
	var save_path: String = "user://data.save"
	var save_file: FileAccess = FileAccess.open(save_path, FileAccess.WRITE)

	var json_data: Dictionary[String, String] = {}
	for var_keys in vars:
		var var_data = vars[var_keys]
		var var_type: int = typeof(var_data)

		if var_type == TYPE_FLOAT:												# float
			json_data[var_keys] = str(var_data)
		elif var_type == TYPE_PACKED_FLOAT64_ARRAY: 							# NOTE: avoid Array[float]
			json_data[var_keys] = "Array[float]("+str(var_data)+")"
		else:
			json_data[var_keys] = var_to_str(var_data)							# add type hints

	save_data[node_name] = JSON.stringify(json_data, "\t", false, true)
	save_file.store_string(JSON.stringify(save_data, "\t", false, true))
