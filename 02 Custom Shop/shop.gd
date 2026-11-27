@tool
class_name Shop
extends Control

# 086 Coin Flip Auto

# _vars()
	# load all item nodes
	# load all info
	# price based on info

# _load() & _save()

# _update_stat()
	# emits .on_buy() signal

# _on_skill_pressed()
	# level check
	# price check
	# unlock check
	# _save()

# _on_skill_entered()
# _on_skill_exited()
	# gives popup w/ information

signal on_buy(stat: Stats, val: float, price: int)								# update stats on other systems
signal on_mouse_entered(pos: Vector2, info: PackedStringArray)					# show popup w/ skill information
signal on_mouse_exited

enum Skill {																	# skills to buy
	MINIONS_UNLOCK,

	COPPER_ADD,
	COPPER_ADD_2,
	COPPER_PERCENT,

	SILVER_ADD,
	SILVER_PERCENT,
}

# const Stats = Main.Stats														# should be on main.gd
enum Stats {
	MINIONS_UNLOCK,
	MINIONS_DASH,
	MINIONS_SPEED,
	MINIONS_REST,

	COPPER_BASE,
	COPPER_MULT,
	SILVER_BASE,
	SILVER_MULT,
}

@export var _skill_infos: Dictionary[Skill, ShopInfo]

var _skill_array: Array[ShopItem]
var _skill_level: PackedInt32Array
var _skill_price: Array[PackedInt64Array]

var _score: int = 10000

@onready var _parent: = get_child(0).get_child(0) as VBoxContainer


func _vars() -> void:
	_skill_array.clear()														# NOTE: GET NODES
	for node in _parent.get_children():
		_skill_array.append(node)

	_skill_infos.clear()														# NOTE: GET INFOS
	for skill in Skill.size():
		_skill_infos[skill] = _skill_array[skill].get_info()

	if Engine.is_editor_hint() == true:											# avoid on editor load errors
		return

	for i in Skill.size():														# TASK: SETUP NODES
		_skill_array[i].pressed.connect(_on_skill_pressed.bind(i))
		_skill_array[i].mouse_entered.connect(_on_skill_entered.bind(i))
		_skill_array[i].mouse_exited.connect(_on_skill_exited)

	_skill_price.resize(Skill.size())											# NOTE: COMPUTE ALL PRICES
	for i in Skill.size():														# base + (base * mult * lvl)
		var cost_base: float = _skill_infos[i].cost_base
		var cost_mult: float = _skill_infos[i].cost_mult
		var level_max: int = _skill_infos[i].level_max

		_skill_price[i].resize(level_max)
		for level in level_max:
			_skill_price[i][level] = int(cost_base + (cost_base * cost_mult * level))


func _load() -> void:															# "_vars" = _vars (lua syntax)
	var vars: Dictionary = {													# prevents misspelling
		_skill_level = _skill_level,
	}

	if MySave.init(self, vars) == false:										# load data to vars
		if _skill_level.is_empty():												# handle empty containers here
			_skill_level.resize(_skill_array.size())

		for stat in Stats.size():
			_update_stat(stat)

		for skill in _skill_array:
			skill.set_level(_skill_level[skill.index])
			skill.unlock_check()


func _save() -> void:															# "_vars" = _vars (lua syntax)
	var vars: Dictionary = {													# prevents misspelling
		_skill_level = _skill_level,
	}

	MySave.save(self, vars)


func _ready() -> void:
	_vars()
	_load()


func set_score(value : int) -> void:
	_score = value


func _update_stat(skill: Skill, price: int = 0) -> void:						# NOTE: STATS UPDATE
	var value: float = 0.0														# separate, used by _save()
	match skill:
		Skill.COPPER_ADD,\
		Skill.COPPER_ADD_2:
			value += _skill_level[Skill.COPPER_ADD] * _skill_infos[Skill.COPPER_ADD].value
			value += _skill_level[Skill.COPPER_ADD_2] * _skill_infos[Skill.COPPER_ADD_2].value

			on_buy.emit(Stats.COPPER_BASE, value, price)

		Skill.COPPER_PERCENT:
			value = _skill_level[Skill.COPPER_PERCENT] * _skill_infos[Skill.COPPER_PERCENT].value
			on_buy.emit(Stats.COPPER_MULT, value, price)

		Skill.SILVER_ADD:
			value = _skill_level[Skill.SILVER_ADD] * _skill_infos[Skill.SILVER_ADD].value
			on_buy.emit(Stats.SILVER_BASE, value, price)

		Skill.SILVER_PERCENT:
			value = _skill_level[Skill.SILVER_PERCENT] * _skill_infos[Skill.SILVER_PERCENT].value
			on_buy.emit(Stats.SILVER_MULT, value, price)


func _on_skill_pressed(skill: Skill) -> void:									# NOTE: SKILL PRESS
	var skill_level: int = _skill_level[skill]
	if skill_level == _skill_infos[skill].level_max:							# max level
		return

	var skill_price: int = _skill_price[skill][skill_level]
	if _score < skill_price:													# score too low
		return

	_skill_level[skill] += 1
	_skill_array[skill].set_level(_skill_level[skill])
	_skill_array[skill].unlock_check()

	_update_stat(skill, skill_price)											# separate, used by _save()
	_on_skill_entered(skill)													# update MyPopover

	_save()


func _on_skill_entered(skill: Skill) -> void:									# NOTE: SKILL HOVER
	var node: ShopItem = _skill_array[skill]
	var title: String = _skill_infos[skill].title

	var level: int = _skill_level[skill]
	var level_max: int = _skill_infos[skill].level_max
	var value: float = _skill_infos[skill].value

	var effect_curr: float = value * level
	var effect_next: float = value * (level + 1)

	var body: String
	match skill:
		Skill.MINIONS_UNLOCK:
			body = "unlock all minions"

		Skill.COPPER_ADD,\
		Skill.COPPER_ADD_2:
			if level < level_max:
				body = "+%s > +%s cent\nper copper flip" % [int(effect_curr), int(effect_next)]
			else:
				body = "+%s cent\nper copper flip" % [int(effect_curr)]

		Skill.COPPER_PERCENT:
			if level < level_max:
				body = "+%s%% > +%s%% cent\nper copper flip" % [int(effect_curr * 100.0), int(effect_next * 100.0)]
			else:
				body = "+%s%% cent\nper copper flip" % [int(effect_curr * 100.0)]

		Skill.SILVER_ADD:
			if level < level_max:
				body = "+%s > +%s cent\nper silver flip" % [int(effect_curr), int(effect_next)]
			else:
				body = "+%s cent\nper silver flip" % [int(effect_curr)]

		Skill.SILVER_PERCENT:
			if level < level_max:
				body = "+%s%% > +%s%% cent\nper silver flip" % [int(effect_curr * 100.0), int(effect_next * 100.0)]
			else:
				body = "+%s%% cent\nper silver flip" % [int(effect_curr * 100.0)]

	var price: int
	var price_text: String
	if level < level_max:
		price = _skill_price[skill][level]
		price_text = "¢%s - Level %s/%s" % [price, level, level_max]
	else:
		price_text = "Level %s/%s" % [level, level_max]

	on_mouse_entered.emit(node.position, [title, body, price_text])
	print("%s | %s | %s" % [title, body, price_text])


func _on_skill_exited() -> void:
	on_mouse_exited.emit()


#region Tools
@export_group("Node Settings")
@export var _icon_folder: String = "Icons"
@export var _info_folder: String = "Infos"
@export var _node_scene: PackedScene = preload("shop_item.tscn")

@export_group("Node Create")
@export_tool_button("Node Spawn", "VcsBranches") var spawn = _spawn
@export_tool_button("Node Icons", "VcsBranches") var icons = _icons
@export_tool_button("Node Infos", "VcsBranches") var infos = _infos

@export_group("Node Position")
@export_tool_button("Position Store", "Save") var store = _place.bind("save")
@export_tool_button("Position Apply", "ScriptExtend") var place = _place.bind("load")

@export_group("", "")
@export_tool_button("Node Refresh", "PreviewRotate") var refresh = _refresh

var _node_array: Array[ShopItem]


func _refresh() -> void:
	_node_array.clear()
	for node in _parent.get_children():
		_node_array.append(node)

	var icon_path: String = get_script().get_path().get_base_dir() + "/" + _icon_folder + "/"
	var info_path: String = get_script().get_path().get_base_dir() + "/" + _info_folder + "/"
	var icon_array: PackedStringArray = ResourceLoader.list_directory(icon_path)
	var info_array: PackedStringArray = ResourceLoader.list_directory(info_path)

	if icon_array.size() != _node_array.size():
		_icons()

	if info_array.size() != _node_array.size():
		_infos()

	for index in _node_array.size():
		_node_array[index].set_icon(load(icon_path + icon_array[index]))
		_node_array[index].set_info(load(info_path + info_array[index]))


func _spawn() -> void:
	var enum_keys: PackedStringArray = Skill.keys()
	var node_scene: PackedScene = _node_scene
	var node_parent: Control = _parent
	var node_fresh: ShopItem

	var node_array: Array[ShopItem]												# NOTE: GET CURRENT NODES
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
	var enum_keys: PackedStringArray = Skill.keys()
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
	var enum_keys: PackedStringArray = Skill.keys()								# enum names
	var file_path: String = get_script().get_path().get_base_dir() + "/" + _info_folder + "/"
	var file_fresh: = ShopInfo.new()

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
			var name_index: String = file_array[file_index].substr(0, 3)		# index in name

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
	var node_array: Array[ShopItem]
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
