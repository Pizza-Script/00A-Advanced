@tool
class_name NodeEnum
extends Node2D

enum Skill
{
	SKILL_A,
	SKILL_B,
	SKILL_C,
}

#region Tools
@export_group("Tool Setup")
@export var _node_scene: PackedScene = preload("skill_tree_node.tscn")
@export var _icon_temp: String = "000_placeholder.png"
@export var _icon_folder: String = "Icons"
@export var _info_folder: String = "Infos"
@export_tool_button("Setup Nodes", "VcsBranches") var setup = _setup

@export_group("Save Position")
@export_tool_button("Position Store", "Save") var store = _place.bind(false)
@export_tool_button("Position Apply", "ScriptExtend") var place = _place.bind(true)

@export_group("", "")
@export_tool_button("Refresh Nodes", "PreviewRotate") var refresh = _refresh

var _node_array: SkillTreeNode


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


var _setup_gaurd: bool = false
func _setup() -> void:
	if _setup_gaurd == true:                                                    # true when icon/info is renamed or created
		printerr("Icon or Info changed, must restart editor")
		return

	_spawn()
	_icons()
	_infos()

	_place(false)


# NOTE: save position if enum has changed

func _spawn() -> void:                                                          # NOTE: CREATE NODES
	var enum_keys: PackedStringArray = Skill.keys()
	var node_scene: PackedScene = _node_scene
	var node_parent: Node2D = self
	var node_fresh: SkillTreeNode

	var node_alive: Array[SkillTreeNode]                                        # NOTE: GET CURRENT NODES
	var node_check: PackedStringArray
	var name_index: PackedInt32Array
	var node_extra: Array[bool]
	for node in node_parent.get_children():
		node_alive.append(node)
		node_check.append(node.name.substr(4))                                  # name w/o index
		name_index.append(int(node.name.substr(0, 3)))                          # index w/n name
		node_extra.append(true)

	var enum_extra: PackedInt32Array
	for index in enum_keys.size():                                              # NOTE: NAME CHECK
		var enum_name: String = enum_keys[index].to_pascal_case()               # SKILL_NAME > SkillName

		if node_check.has(enum_name) == true:                                   # node w/ enum name exists
			var check_index: int = node_check.find(enum_name)                   # index in check
			var _name_index: int = name_index[check_index]                      # index in name

			if index != _name_index:                                            # index is wrong
				var new_name: = "%03d_" % index + enum_name                     # SkillName > 001_SkillName
				print("Renamed Node: %s to %s" % [node_alive[_name_index].name, new_name])

				node_parent.move_child(node_alive[_name_index], index)
				node_alive[_name_index].name = new_name

			node_extra[check_index] = false                                     # not an extra file
		else:
			enum_extra.append(index)                                            # enum w/o a file

	if node_extra.has(true) || enum_extra.is_empty() == false:                  # NOTE: INDEX CHECK
		var extra_name_index: PackedInt32Array
		var extra_node_index: PackedInt32Array
		for index in node_extra.size():
			if node_extra[index] == true:
				extra_name_index.append(name_index[index])
				extra_node_index.append(index)                                  # node_alive index

		var array_index: int = 0
		for enum_index in enum_extra:
			if extra_name_index.has(enum_index):                                # extras index has enum index
				var index: int = extra_node_index[extra_name_index.find(enum_index)]
				var new_name: = "%03d_" % index + enum_keys[index].to_pascal_case()
				print("Renamed Node: %s to %s" % [node_alive[index].name, new_name])

				node_parent.move_child(node_alive[index], index)
				node_alive[index].name = new_name                               # 001_SkillName

				node_extra[index] = false
				enum_extra[array_index] = -1
				array_index += 1

		for index in enum_extra:                                                # NOTE: NODE MISSING
			if index == -1:
				continue

			node_fresh = node_scene.instantiate()                               # create new node
			node_parent.add_child(node_fresh)
			node_parent.move_child(node_fresh, index)
			node_fresh.owner = get_tree().edited_scene_root
			node_fresh.name = "%03d_" % index + enum_keys[index].to_pascal_case()
			print("Created Node: %s" % node_fresh.name)

	if node_extra.has(true):                                                    # NOTE: NODE EXTRA
		for index in node_extra.size():
			if node_extra[index] == true:
				print("Extra Node: %03d_" % name_index[index] + node_check[index])

	print("Nodes Set")


func _place(is_load: bool) -> void:
	var node_array: Array[SkillTreeNode] = get_nodes()
	var place_array: Array[Vector2] = [Vector2(160.0, 90.0), Vector2(160.0, 58.0),
			Vector2(192.0, 90.0), Vector2(160.0, 122.0), Vector2(128.0, 90.0),
			Vector2(160.0, 154.0), Vector2(160.0, 24.0)]
	var place_line: int = get_stack()[0]["line"] - 1

	if is_load == true:                                                         # NOTE: APPLY POSITIONS
		var undo_redo = get_tree().get_root().find_children("*", "EditorPlugin", true, false)[0].get_undo_redo()
		for index in node_array.size():
			undo_redo.create_action("Apply Position : " + node_array[index].name) # apply for each node
			undo_redo.add_do_property(node_array[index], "position", place_array[index])
			undo_redo.add_undo_property(node_array[index], "position", node_array[index].position)
			undo_redo.commit_action()

	elif is_load == false:                                                      # NOTE: GENERATE STRING
		var positions: String = "\tvar place_array: Array[Vector2] = ["
		for index in node_array.size() - 1:
			positions += "Vector2%s, " % node_array[index].position
			if (index - 1) % 3 == 0:
				positions += "\n\t\t\t"
		positions +=  "Vector2%s]" % node_array[-1].position

		print("Node Positions added to Clipboard")
		DisplayServer.clipboard_set(positions)                                  # add to clipboard
		var editor_interface = Engine.get_singleton(&"EditorInterface")
		editor_interface.set_main_screen_editor("Script")
		editor_interface.edit_script(get_script(), place_line, true)            # focus on script & line


func _icons() -> void:
	var enum_keys: PackedStringArray = Skill.keys()
	var file_path: String = _icon_folder

	file_path = get_script().get_path().get_base_dir() + "/" + file_path + "/"
	var file_alive: PackedStringArray = ResourceLoader.list_directory(file_path) # files in folder
	var file_check: PackedStringArray                                           # file name (index removed)
	var file_extra: Array[bool]
	for index in file_alive.size():
		file_check.append(file_alive[index].substr(4))
		file_extra.append(true)

	var enum_extra: PackedInt32Array
	for index in enum_keys.size():                                              # NOTE: NAME CHECK
		var file_name: String = enum_keys[index].to_lower() + ".png"            # GOLD > gold.png

		if file_check.has(file_name) == true:                                   # file w/ enum name exists
			var check_index: int = file_check.find(file_name)                   # index in check
			var alive_index: int = int(file_alive[check_index].substr(0, 3))    # index in name

			if index != alive_index:                                            # index is wrong
				var old_name: String = "%03d_" % alive_index + file_name
				file_name = "%03d_" % index + file_name
				DirAccess.rename_absolute(file_path + old_name, file_path + file_name)
				print("Renamed Icon: %s to %s" % [old_name, file_name])
				_setup_gaurd = true

			file_extra[check_index] = false                                     # not an extra file
		else:
			enum_extra.append(index)                                            # enum w/o a file

	if file_extra.has(true) && enum_extra.is_empty() == false:                  # NOTE: INDEX CHECK
		var file_index: PackedInt32Array                                        # file_alive index
		var name_index: PackedInt32Array                                        # index w/n name
		for index in file_extra.size():
			if file_extra[index] == true:
				file_index.append(index)
				name_index.append(int(file_alive[index].substr(0, 3)))

		var array_index: int = 0
		for enum_index in enum_extra:
			if name_index.has(enum_index):                                      # index matched
				var alive_index: int = file_index[name_index.find(enum_index)]
				var old_name: String = file_alive[alive_index]
				var new_name: String = "%03d_" % enum_index + enum_keys[enum_index].to_lower() + ".png"

				DirAccess.rename_absolute(file_path + old_name, file_path + new_name)
				print("Renamed Icon: %s to %s" % [old_name, new_name])
				_setup_gaurd = true

				file_extra[alive_index] = false
				enum_extra[array_index] = -1
				array_index += 1

	for index in enum_extra:                                                    # NOTE: FILE MISSING
		if index != -1:
			var file_name: = "%03d_" % index + enum_keys[index].to_lower() + ".png"
			DirAccess.copy_absolute(file_path + _icon_temp, file_path + file_name)
			print("Created Icon: %s" % file_path + file_name)
			_setup_gaurd = true


	if file_extra.has(true):                                                    # NOTE: FILE EXTRA
		for index in file_extra.size():
			if file_extra[index] == true && file_alive[index] != _icon_temp:
				print("Extra Icon : %s" % file_alive[index])

	notify_property_list_changed()                                              # refresh inspector
	print("Icons set")


func _infos() -> void:
	var enum_keys: PackedStringArray = Skill.keys()                             # enum names
	var file_path: String = get_script().get_path().get_base_dir() + "/" + _info_folder + "/"
	var file_fresh: = SkillTreeInfo.new()

	var file_alive: PackedStringArray = ResourceLoader.list_directory(file_path) # files in folder
	var file_check: PackedStringArray
	var name_index: PackedInt32Array
	var file_extra: Array[bool]
	for index in file_alive.size():
		file_check.append(file_alive[index].substr(4))                          # name w/o index
		name_index.append(int(file_alive[index].substr(0, 3)))                  # index w/n name
		file_extra.append(true)

	var enum_extra: PackedInt32Array
	for index in enum_keys.size():                                              # NOTE: NAME CHECK
		var file_name: String = enum_keys[index].to_lower() + ".tres"           # GOLD > gold.tres

		if file_check.has(file_name) == true:                                   # file w/ enum name exists
			var check_index: int = file_check.find(file_name)                   # index in check
			var _name_index: int = name_index[check_index]                      # index in name

			if index != _name_index:                                            # index is wrong
				var old_name: = "%03d_" % _name_index + file_name
				var new_name: = "%03d_" % index + file_name
				DirAccess.rename_absolute(file_path + old_name, file_path + new_name)
				print("Renamed Info: %s to %s" % [old_name, new_name])
				_setup_gaurd = true

			file_extra[check_index] = false                                     # not an extra file
		else:
			enum_extra.append(index)                                            # enum w/o a file

	if file_extra.has(true) && enum_extra.is_empty() == false:                  # NOTE: INDEX CHECK
		var extra_name_index: PackedInt32Array
		var extra_file_index: PackedInt32Array
		for index in file_extra.size():
			if file_extra[index] == true:
				extra_name_index.append(int(file_alive[index].substr(0, 3)))
				extra_file_index.append(index)                                  # file_alive index

		var array_index: int = 0
		for enum_index in enum_extra:
			if extra_name_index.has(enum_index):                                # extras index has enum index
				var index: int = extra_file_index[extra_name_index.find(enum_index)]

				var old_name: String = file_alive[index]
				var new_name: String = "%03d_" % enum_index + enum_keys[enum_index].to_lower() + ".tres"
				DirAccess.rename_absolute(file_path + old_name, file_path + new_name)
				print("Renamed Info: %s to %s" % [old_name, new_name])
				_setup_gaurd = true

				file_extra[index] = false
				enum_extra[array_index] = -1
				array_index += 1

	for index in enum_extra:                                                    # NOTE: FILE MISSING
		if index != -1:
			var file_name: String = "%03d_" % index + enum_keys[index].to_lower() + ".tres"
			ResourceSaver.save(file_fresh, file_path + file_name)
			print("Created Info: " + file_name)

	if file_extra.has(true):                                                    # NOTE: FILE EXTRA
		for index in file_extra.size():
			if file_extra[index] == true:
				print("Extra Info : %s" % file_alive[index])

	notify_property_list_changed()                                              # refresh inspector
	print("Infos set")

#endregion
