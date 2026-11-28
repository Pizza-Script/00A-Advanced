@tool
class_name ShopNested
extends Control

# data hardcoded into the code

# uses "Dictionary to Array[Array]" Nested Data
# uses MySave _save() / _load()
# uses Editor Enum functions

signal on_item_buy(type: int)

enum Item
{
	COPPER,
	SILVER,
	GOLD,
	TUNGSTEN,
	PALLADIUM,
}

enum Info
{
	COST_BASE,
	COST_MULT,
}

var _data_array: Array[Array]
var _node_array: Array[ShopNestedItem]

var _shop_level: PackedInt32Array
var _shop_price: Array[PackedInt64Array]

var _coins: int = 10000


func _enum() -> void:
	var items: Dictionary[int, Dictionary]

	items[Item.COPPER] = {
		Info.COST_BASE : 50.0,
		Info.COST_MULT : 1.2,
	}

	items[Item.SILVER] = {
		Info.COST_BASE : 100.0,
		Info.COST_MULT : 1.2,
	}

	items[Item.GOLD] = {
		Info.COST_BASE : 200,
		Info.COST_MULT : 1.2,
	}

	items[Item.TUNGSTEN] = {
		Info.COST_BASE : 250,
		Info.COST_MULT : 1.2,
	}

	items[Item.PALLADIUM] = {
		Info.COST_BASE : 300,
		Info.COST_MULT : 1.2,
	}

	for index in Item.size():													# NOTE: DICTIONARY TO ARRAYS
		_data_array.append([])													# programmatic, not semantic
		for info in Info.size():
			_data_array[index].append(items[index][info])


func _vars() -> void:
	_node_array.clear()															# NOTE: GET NODES
	for node in get_children():
		_node_array.append(node)

	var item_keys: = Item.keys() as PackedStringArray
	for i in Item.size():														# NOTE: SETUP NODES
		_node_array[i].pressed.connect(_on_item_pressed.bind(i))
		_node_array[i].set_title(item_keys[i])


func _load() -> void:
	var vars: Dictionary = {
		_shop_level = _shop_level,												# "_vars" = _vars (lua syntax)
	}																			# prevents misspelling

	if MySave.init(self, vars) == true:											# load data to vars
		_shop_level.resize(Item.size())											# no data, handle empty containers

	for index in _node_array.size():
		_node_array[index].set_level(_shop_level[index])


func _save() -> void:
	var vars: Dictionary = {													# "_vars" = _vars (lua syntax)
		_shop_level = _shop_level,												# prevents misspelling
	}

	MySave.save(self, vars)


func _ready() -> void:
	_enum()
	_vars()
	_load()


func _on_item_pressed(index: int) -> void:
	on_item_buy.emit(index)

	var cost_base: float = _data_array[index][Info.COST_BASE]					# NOTE: PRICE CHECK
	var cost_mult: float = _data_array[index][Info.COST_MULT]
	var price: = int(cost_base + (cost_base * cost_mult * _shop_level[index]))

	if _coins < price:
		return

	_coins -= price

	_shop_level[index] += 1
	_node_array[index].set_level(_shop_level[index])
	_save()


#region Tools
@export_group("Tool Create")
@export var _icon_folder: String = "Icons"
@export var _shop_item: PackedScene = preload("shop_nested_item.tscn")

@export_group("Node Create")
@export_tool_button("Node Spawn", "VcsBranches") var spawn = _spawn
@export_tool_button("Node Icons", "VcsBranches") var icons = _icons

@export_group("Node Position")
@export_tool_button("Position Store", "Save") var store = _place.bind("save")
@export_tool_button("Position Apply", "ScriptExtend") var place = _place.bind("load")


func _spawn() -> void:															# NOTE: CREATE NODES
	var enum_keys: PackedStringArray = Item.keys()
	var node_scene: PackedScene = _shop_item
	var node_parent: Control = self
	var node_fresh: ShopNestedItem

	var node_array: Array[ShopNestedItem]										# NOTE: GET CURRENT NODES
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
			var name_index: String = node_array[node_index].name.substr(0, 3)	# index in name

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
	var enum_keys: PackedStringArray = Item.keys()
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


func _place(type: String) -> void:
	var node_array: Array[ShopNestedItem]
	for node in get_children():
		node_array.append(node)

	var place_array: Array[Vector2] = [Vector2(0.0, 0.0), Vector2(0.0, 24.0),
		Vector2(0.0, 48.0), Vector2(0.0, 72.0), Vector2(0.0, 96.0)]
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
