@tool
class_name NodeEnum
extends Node2D

# used in "087 Coin Flip Tree" as SkillTree

enum Nodes
{
	NODE_A,
	NODE_B,
	NODE_C,
}

#region Tools
@export_group("Node Settings")
@export var _icon_folder: String = "Icons"
@export var _info_folder: String = "Infos"
@export var _node_scene: PackedScene = preload("node_enum_item.tscn")

@export_group("Node Create")
@export_tool_button("Node Spawn", "VcsBranches") var spawn = _spawn
@export_tool_button("Node Icons", "VcsBranches") var icons = _icons
@export_tool_button("Node Infos", "VcsBranches") var infos = _infos

@export_group("Node Position")
@export_tool_button("Position Store", "Save") var store = _place.bind("save")
@export_tool_button("Position Apply", "ScriptExtend") var place = _place.bind("load")

@export_group("", "")
@export_tool_button("Node Refresh", "PreviewRotate") var refresh = _refresh

var _node_array: Array[NodeEnumItem]


func _refresh() -> void:
	_node_array.clear()
	for node in get_children():
		_node_array.append(node)

	var icon_path: String = get_script().get_path().get_base_dir() + "/" + _icon_folder + "/"
	var info_path: String = get_script().get_path().get_base_dir() + "/" + _info_folder + "/"
	var icon_array: PackedStringArray = ResourceLoader.list_directory(icon_path)
	var info_array: PackedStringArray = ResourceLoader.list_directory(info_path)

	for index in _node_array.size():
		_node_array[index].set_icon(load(icon_path + icon_array[index]))
		_node_array[index].set_info(load(info_path + info_array[index]))


func _spawn() -> void:															# NOTE: CREATE NODES
	var enum_keys: PackedStringArray = Nodes.keys()
	var node_scene: PackedScene = _node_scene
	var node_parent: Node2D = self
	var node_fresh: NodeEnumItem

	var node_array: Array[NodeEnumItem]											# NOTE: GET CURRENT NODES
	var node_names: PackedStringArray
	for node in node_parent.get_children():
		node_array.append(node)
		if node.name.substr(0, 3).is_valid_int() == true:						# has valid index in name
			node_names.append(node.name.substr(4))
		else:																	# name has no index
			node_names.append(node.name)										# can still check name for enum

	var enum_extra: PackedInt32Array											# enum w/o file
	var node_extra: Array[bool]													# file w/o enum
	node_extra.resize(node_array.size())
	node_extra.fill(true)

	for index in enum_keys.size():												# NOTE A: NAME CHECK
		var enum_name: String = enum_keys[index].to_pascal_case()				# SKILL_NAME > SkillName

		if node_names.has(enum_name) == true:									# file name & enum name matches
			var node_index: int = node_names.find(enum_name)					# index in parent
			var name_index: String = node_array[node_index].name.substr(0, 3) 	# index in name

			if name_index.is_valid_int() == false:								# int(invalid_int string) = 0
				name_index = "-1"

			if index != int(name_index):										# enum index & file name index does not match
				var old_name: = node_array[node_index].name
				var new_name: = "%03d_" % index + enum_name						# SkillName > 001_SkillName

				node_parent.move_child(node_array[node_index], index)
				node_array[node_index].name = new_name
				print("Renamed Node: %s to %s" % [old_name, new_name])

			node_extra[node_index] = false										# node has enum
		else:
			enum_extra.append(index)											# enum w/o a node

	if node_extra.has(true) || enum_extra.is_empty() == false:					# NOTE B: INDEX CHECK
		var name_index_array: PackedInt32Array									# index in name
		var node_index_array: PackedInt32Array									# index in parent
		for index in node_array.size():
			if node_extra[index] == true:										# file w/o enum
				var index_string: = node_array[index].name.substr(0, 3)			# check if valid index
				if index_string.is_valid_int() == true:							# invalid int string = 0
					name_index_array.append(int(index_string))
					node_index_array.append(index)

		var array_index: int = -1												# enum_extra array index
		for enum_index in enum_extra:											# enum w/o file
			array_index += 1

			if name_index_array.has(enum_index):								# extras index has enum index
				var name_index: int = name_index_array.find(enum_index)
				var node_index: int = node_index_array[name_index]

				var old_name: String = node_array[node_index].name
				var new_name: String = "%03d_" % enum_index + enum_keys[enum_index].to_pascal_case()

				node_parent.move_child(node_array[node_index], enum_index)
				node_array[node_index].name = new_name							# 001_SkillName
				print("Renamed Node: %s to %s" % [old_name, new_name])

				node_extra[node_index] = false
				enum_extra[array_index] = -1

	for index in enum_extra:													# NOTE C: NODE MISSING
		if index != -1:
			node_fresh = node_scene.instantiate()
			node_parent.add_child(node_fresh)
			node_parent.move_child(node_fresh, index)
			node_fresh.owner = get_tree().edited_scene_root
			node_fresh.name = "%03d_" % index + enum_keys[index].to_pascal_case()
			print("Created Node: %s" % node_fresh.name)

	if node_extra.has(true):													# NOTE D: NODE EXTRA
		for index in node_extra.size():
			if node_extra[index] == true:
				print("Extra Node: %%s" % node_array[index])

	print("Nodes Set")


func _icons() -> void:
	var enum_keys: PackedStringArray = Nodes.keys()
	var file_path: String = get_script().get_path().get_base_dir() + "/" + _icon_folder + "/"

	var file_array: PackedStringArray = ResourceLoader.list_directory(file_path) # files in folder
	var file_names: PackedStringArray											# file name w/o index
	for index in file_array.size():
		if file_array[index].substr(0, 3).is_valid_int() == true:				# has valid index in name
			file_names.append(file_array[index].substr(4))
		else:																	# name has no index
			file_names.append(file_array[index])								# can still check name for enum

	var enum_extra: PackedInt32Array											# enum w/o file
	var file_extra: Array[bool]													# file w/o enum
	file_extra.resize(file_array.size())
	file_extra.fill(true)

	for index in enum_keys.size():												# NOTE A: NAME CHECK
		var enum_name: String = enum_keys[index].to_lower() + ".png"			# GOLD > gold.png

		if file_names.has(enum_name) == true:									# file name & enum name matches
			var file_index: int = file_names.find(enum_name)					# index in folder
			var name_index: String = file_array[file_index].substr(0, 3)		# index in name

			if name_index.is_valid_int() == false:								# int(invalid_int string) = 0
				name_index = "-1"

			if index != int(name_index):										# enum index & file name index does not match
				var old_name: String = file_array[file_index]
				var new_name: = "%03d_" % index + enum_name

				DirAccess.rename_absolute(file_path + old_name, file_path + new_name)
				print("Renamed Icon: %s to %s" % [old_name, new_name])

			file_extra[file_index] = false										# file has enum
		else:
			enum_extra.append(index)											# enum w/o a file

	if file_extra.has(true) && enum_extra.is_empty() == false:					# NOTE B: INDEX CHECK
		var name_index_array: PackedInt32Array									# index in name
		var file_index_array: PackedInt32Array									# index in folder
		for index in file_array.size():
			if file_extra[index] == true:										# file w/o enum
				var index_string: String = file_array[index].substr(0, 3)		# check if valid index
				if index_string.is_valid_int() == true:							# invalid int string = 0
					name_index_array.append(int(index_string))
					file_index_array.append(index)

		var array_index: int = -1												# enum_extra array index
		for enum_index in enum_extra:											# enum w/o file
			array_index += 1

			if name_index_array.has(enum_index):								# file name index & enum index matched
				var name_index: int = name_index_array.find(enum_index)
				var file_index: int = file_index_array[name_index]

				var old_name: String = file_array[file_index]
				var new_name: String = "%03d_" % enum_index + enum_keys[enum_index].to_lower() + ".png"

				DirAccess.rename_absolute(file_path + old_name, file_path + new_name)
				print("Renamed Icon: %s to %s" % [old_name, new_name])

				file_extra[file_index] = false
				enum_extra[array_index] = -1

	for index in enum_extra:													# NOTE C: FILE MISSING
		if index != -1:
			var file_name: = "%03d_" % index + enum_keys[index].to_lower() + ".png"
			print("Missing Icon: %s" % file_path + file_name)

	if file_extra.has(true):													# NOTE D: FILE EXTRA
		for index in file_extra.size():
			if file_extra[index] == true:
				print("Extra Icon : %s" % file_array[index])

	notify_property_list_changed()												# refresh inspector
	print("Icons set")


func _infos() -> void:
	var enum_keys: PackedStringArray = Nodes.keys()								# enum names
	var file_path: String = get_script().get_path().get_base_dir() + "/" + _info_folder + "/"
	var file_fresh: = NodeEnumInfo.new()

	var file_array: PackedStringArray = ResourceLoader.list_directory(file_path) # files in folder
	var file_names: PackedStringArray											# file name w/o index
	for index in file_array.size():
		if file_array[index].substr(0, 3).is_valid_int() == true:				# has valid index in name
			file_names.append(file_array[index].substr(4))
		else:																	# name has no index
			file_names.append(file_array[index])								# can still check name for enum

	var enum_extra: PackedInt32Array											# enum w/o file
	var file_extra: Array[bool]													# file w/o enum
	file_extra.resize(file_array.size())
	file_extra.fill(true)

	for index in enum_keys.size():												# NOTE: NAME CHECK
		var enum_name: String = enum_keys[index].to_lower() + ".tres"			# GOLD > gold.tres

		if file_names.has(enum_name) == true:									# file name & enum name matches
			var file_index: int = file_names.find(enum_name)					# index in folder
			var name_index: String = file_array[file_index].substr(0, 3) 		# index in name

			if name_index.is_valid_int() == false:								# int(invalid_int string) = 0
				name_index = "-1"

			if index != int(name_index):										# enum index & file name index does not match
				var old_name: = file_array[file_index]
				var new_name: = "%03d_" % index + enum_name

				DirAccess.rename_absolute(file_path + old_name, file_path + new_name)
				print("Renamed Info: %s to %s" % [old_name, new_name])

			file_extra[file_index] = false										# file has enum
		else:
			enum_extra.append(index)											# enum w/o a file

	if file_extra.has(true) && enum_extra.is_empty() == false:					# NOTE B: INDEX CHECK
		var name_index_array: PackedInt32Array									# index in name
		var file_index_array: PackedInt32Array									# index in folder
		for index in file_array.size():
			if file_extra[index] == true:										# file w/o enum
				var index_string: String = file_array[index].substr(0, 3)		# check if valid index
				if index_string.is_valid_int() == true:							# invalid int string = 0
					name_index_array.append(int(index_string))
					file_index_array.append(index)

		var array_index: int = -1												# enum_extra array index
		for enum_index in enum_extra:											# enum w/o file
			array_index += 1

			if name_index_array.has(enum_index):								# extras index has enum index
				var name_index: int = name_index_array.find(enum_index)
				var file_index: int = file_index_array[name_index]

				var old_name: String = file_array[file_index]
				var new_name: String = "%03d_" % enum_index + enum_keys[enum_index].to_lower() + ".tres"

				DirAccess.rename_absolute(file_path + old_name, file_path + new_name)
				print("Renamed Info: %s to %s" % [old_name, new_name])

				file_extra[file_index] = false
				enum_extra[array_index] = -1

	for index in enum_extra:													# NOTE C: FILE MISSING
		if index != -1:
			var file_name: String = "%03d_" % index + enum_keys[index].to_lower() + ".tres"
			ResourceSaver.save(file_fresh, file_path + file_name)
			print("Created Info: " + file_name)

	if file_extra.has(true):													# NOTE D: FILE EXTRA
		for index in file_extra.size():
			if file_extra[index] == true:
				print("Extra Info : %s" % file_array[index])

	notify_property_list_changed()												# refresh inspector
	print("Infos set")


func _place(type: String) -> void:
	var node_array: Array[NodeEnumItem]
	for node in get_children():
		node_array.append(node)

	var place_array: Array[Vector2] = [Vector2(160.0, 90.0), Vector2(160.0, 58.0),
			Vector2(192.0, 90.0)]
	var place_line: int = get_stack()[0]["line"] - 1

	if type == "load":															# NOTE: APPLY POSITIONS
		var undo_redo = get_tree().get_root().find_children("*", "EditorPlugin", true, false)[0].get_undo_redo()
		for index in node_array.size():
			undo_redo.create_action("Load Position : " + node_array[index].name) # apply for each node
			undo_redo.add_do_property(node_array[index], "position", place_array[index])
			undo_redo.add_undo_property(node_array[index], "position", node_array[index].position)
			undo_redo.commit_action()

	elif type == "save":														# NOTE: GENERATE STRING
		var positions: String = "\tvar place_array: Array[Vector2] = ["
		for index in node_array.size() - 1:
			positions += "Vector2%s, " % node_array[index].position
			if (index - 1) % 3 == 0:
				positions += "\n\t\t\t"
		positions +=	"Vector2%s]" % node_array[-1].position

		print("Node Positions saved to Clipboard")
		DisplayServer.clipboard_set(positions)									# add to clipboard
		var editor_interface = Engine.get_singleton(&"EditorInterface")
		editor_interface.set_main_screen_editor("Script")
		editor_interface.edit_script(get_script(), place_line, true)			# focus on script & line
#endregion
