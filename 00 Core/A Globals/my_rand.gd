@tool
# class_name MyRand																# all about random
extends Node

class_name _MyRand																# class_name for @tool use
static var tool: _MyRand														# singleton name for globals

# MyRand.random(count = 8)
# MyRand.reset()																# reset current seed state
# MyRand.save()

# MyRand.set_code("ABCD0123")
# MyRand.set_seed(86968484287236)
# MyRand.set_state(-8813306757601399482)

# MyRand.get_code()
# MyRand.get_seed()
# MyRand.get_state()

# MyRand.i()					# [0 to 4294967295] 32-bit inclusive
# MyRand.f()					# [+0.0 to +1.0]
# MyRand.i_one()				# 0 or 1
# MyRand.f_one()				# [-1.0 to +1.0]
# MyRand.i_range(5, 20)			# inclusive (5 to 20)
# MyRand.f_range(5, 20)			# inclusive
# MyRand.i_sign()
# MyRand.f_sign()
# MyRand.color()				# 0 - all, 1 - red, 2 - green, 3 - blue
# MyRand.color_hue()

# MyRand.shuffle(_array)
# MyRand.shuffle_int_array(_array)
# MyRand.shuffle_int_packed(_array)

# MyRand.rotation_rad(PI)
# MyRand.rotation_deg(270)
# MyRand.rotation_vector2()

# MyRand.v2_range(_min, _max)

# MyRand.position_in_area(v2_min, v2_max, margin)
# MyRand.position_in_view(margin)
# MyRand.position_in_world(margin)

# MyRand.position_out_area(v2_min, v2_max, region, margin)
# MyRand.position_out_view(region, margin)
# MyRand.position_out_world(region, margin)

# MyRand.pseudo_chance(chance, repetitions)
# if MyRand.pseudo_chance(25, tries) > randf()

var _rng: = RandomNumberGenerator.new()											# default seed length is 19
var _code: String = _encode_base26(_rng.seed)									# produces 14 length code
var _seed: int
var _state: int

var _world_size: Vector2 = MyCore.world_size
var _world_half: Vector2 = MyCore.world_size * 0.5

var _viewport_size: Vector2 = MyCore.viewport_size
var _viewport_half: Vector2 = MyCore.viewport_size * 0.5

var _camera: MyCamera
var _camera_zoom: Vector2
var _camera_size: Vector2
var _camera_half: Vector2
var _camera_position: Vector2													# to handle drag


func _ready() -> void:
	if Engine.is_editor_hint() == true:
		return

	MyCore.on_viewport_edit.connect(_on_viewport_edit)
	MyCore.on_world_edit.connect(_on_world_edit)

	random(8)																	# to randomize every game load
	# save()																	# to load same seed

	tool = self																	# add here to avoid race conditions

	await get_tree().current_scene.ready
	_camera = get_viewport().get_camera_2d()
	if _camera == null:															# for scenes w/o Camera2D (i.e. F6)
		return

	_camera.on_zoom.connect(_on_camera_zoom)
	_camera.on_move.connect(_on_camera_move)

	_camera_zoom = _camera.zoom
	_camera_size = _viewport_size / _camera_zoom
	_camera_half = _viewport_half / _camera_zoom
	_camera_position = _camera.position


func random(length: int = 8) -> void:
	_code = _generate_code(length)
	_rng.seed = _decode_base26(_code)


func reset() -> void:															# NOTE: RESET SEED STATE
	_rng.seed = _decode_base26(_code)											# on seed set, same 1st state is given


func save() -> void:
	var vars: Dictionary = {													# vars to save (lua syntax)
		_code = _code,
		_seed = _seed,
		_state = _state,
	}

	if MySave.is_loaded(self) == false:											# NOTE: LOAD DATA
		MySave.init(self, vars)													# only load once

		_rng.seed = _seed
		_rng.state = _state

	MySave.save(self, vars)


func set_code(code: String) -> void:
	_code = code																# state is changed
	_rng.seed = _decode_base26(_code)											# when seed changes


func set_seed(my_seed: int) -> void:
	_rng.seed = my_seed


func set_state(state: int) -> void:
	_rng.state = state


func get_code() -> String:
	return _code


func get_seed() -> int:
	return _rng.seed


func get_state() -> int:
	return _rng.state


func i() -> int:																# [0 to 4294967295] 32-bit inclusive
	return _rng.randi()															# (_max included)


func f() -> float:																# [+0.0 to +1.0]
	return _rng.randf()


func i_one() -> int:															# 0 or 1
	return i_range(0, 1)


func f_one() -> float:															# [-1.0 to +1.0]
	return f_range(-1.0, +1.0)


func i_range(from: int, to: int) -> int:										# inclusive
	return _rng.randi_range(from, to)											# [20 = 0 to 20]


func f_range(from: float, to: float) -> float:									# inclusive
	return _rng.randf_range(from, to)


func i_sign() -> int:															# -1 or +1
	return +1 if i() % 2 else -1												# [-1, +1][i() % 2] - not type safe


func f_sign() -> float:															# -1.0 or +1.0
	return +1.0 if i() % 2 else -1.0											# [-1.0, +1.0][i() % 2] - not type safe


func color(type: int = 0) -> Color:
	var my_color: Color

	if type == 0:																# 0 - all
		my_color = Color(f(), f(), f(), 1)

	elif type == 1:																# 1 - red
		my_color = Color(1, f(), f(), 1)

	elif type == 2:																# 2 - green
		my_color = Color(f(), 1, f(), 1)

	elif type == 3:																# 3 - blue
		my_color = Color(f(), f(), 1, 1)

	return my_color


func color_hue() -> Color:
	var my_color: Color
	my_color.v = 1.0
	my_color.s = 1.0
	my_color.h = float(i_range(0, 360) / 360.0)
	return my_color


func shuffle(array: Array) -> void:												# works, as array is passed by reference
	var index: int = array.size()												# last item first
	var swap: int
	var temp

	if index < 2:
		return

	for item: int in index - 1:
		index -= 1
		swap = i() % index														# array.shuffle() uses global rng (can't be saved)
		# randi() - inclusive (_max included)
		if swap != index:														# swap index [github.com/godotengine/godot-proposals/issues/3142]
			temp = array[swap]
			array[swap] = array[index]
			array[index] = temp


func shuffle_int_array(array: Array[int]) -> void:								# array passed by reference
	var index: int = array.size()												# last item first
	var swap: int

	if index < 2:
		return

	for item: int in index - 1:
		index -= 1
		swap = i() % index														# array.shuffle() uses global rng (can't be saved)

		if swap != index:														# swap index [github.com/godotengine/godot-proposals/issues/3142]
			array[swap] = array[swap] ^ array[index]							# XOR swap	[youtu.be/DJxEYOC8IRc]
			array[index] = array[swap] ^ array[index]
			array[swap] = array[swap] ^ array[index]


func shuffle_int_packed(array: PackedInt32Array) -> void:
	var index: int = array.size()
	var swap: int

	if index < 2:
		return

	for item: int in index - 1:
		index -= 1
		swap = i() % index

		if swap != index:
			array[swap] = array[swap] ^ array[index]
			array[index] = array[swap] ^ array[index]
			array[swap] = array[swap] ^ array[index]


func rotation_rad(max_radians: float = TAU) -> float:
	return f_range(0.0, max_radians)


func rotation_deg(max_degrees: int = 360) -> int:
	return i() % (max_degrees + 1)


func rotation_vector2() -> Vector2:												# Vector2.RIGHT.rotated(randf_range(-PI/4, PI/4))		# -45 to +45
	return Vector2.RIGHT.rotated(rotation_rad())								# Vector2.RIGHT.rotated(deg_to_rad(randi() % 90 - 45))	# -45 to +45


func v2_range(_min: Vector2, _max: Vector2) -> Vector2i:
	return Vector2(_rng.randf_range(_min.x, _max.x), _rng.randf_range(_min.y, _max.y))


func position_in_area(_min: Vector2, _max: Vector2, margin: float = 0.0) -> Vector2:
	_min += Vector2(margin, margin)
	_max -= Vector2(margin, margin)
	return v2_range(_min, _max)


func position_in_view(margin: float = 0.0) -> Vector2:
	var view_min: Vector2 = _camera_position - _camera_half						# margin > (-) larger view (+) smaller view
	var view_max: Vector2 = _camera_position + _camera_half						# opposite of "out" functions
	return position_in_area(view_min, view_max, margin)


func position_in_world(margin: float = 0.0) -> Vector2:
	return position_in_area(Vector2.ZERO, _world_size, margin)


func position_out_area(_min: Vector2, _max: Vector2, margin: float = 0.0, region: float = 16.0, ratio: bool = false) -> Vector2:
	var margin_v2: Vector2 = Vector2(margin, margin) * -1.0						# (+) larger view (-) smaller view
	var region_v2: Vector2 = Vector2(region, region)							# region > size of spawn area

	var view_min: Vector2 = _min + margin_v2									# view w/ margin
	var view_max: Vector2 = _max - margin_v2									# do not spawn here

	var region_min: Vector2
	var region_max: Vector2														# area of spawn
	var side: int

	if ratio == false:
		side = i_range(0, 3)

	else:
		var wide: float = view_max.x - view_min.x								# higher spawn chance
		var tall: float = view_max.y - view_min.y								# based on side length (v/h)
		var _ratio: float = ((tall / wide) if wide > tall else (wide / tall)) * 0.5	# for even distribution
		side = i_one()															# side to spawn (L / R)

		if wide >= tall && _ratio < f():										# wider or equal
			side += 2															# T / B
		elif wide < tall && _ratio > f():										# taller
			side += 2

	if side == 0:																# L
		region_min = Vector2(view_min.x, view_min.y) - region_v2
		region_max = Vector2(view_min.x, view_max.y + region)

	elif side == 1:																# R
		region_min = Vector2(view_max.x, view_min.y - region)
		region_max = Vector2(view_max.x, view_max.y) + region_v2

	elif side == 2:																# T
		region_min = Vector2(view_min.x, view_min.y) - region_v2
		region_max = Vector2(view_max.x + region, view_min.y)

	elif side == 3:																# B
		region_min = Vector2(view_min.x - region, view_max.y)
		region_max = Vector2(view_max.x, view_max.y) + region_v2

	return v2_range(region_min, region_max)


func position_out_view(margin: float = 0.0, region: float = 16.0, ratio: bool = false) -> Vector2:
	var view_min: Vector2 = _camera_position - _camera_half						# margin > (+) larger view (-) smaller view
	var view_max: Vector2 = _camera_position + _camera_half						# region > size of spawn area
	return position_out_area(view_min, view_max, margin, region, ratio)


func position_out_world(margin: float = 0.0, region: float = 16.0, ratio: bool = false) -> Vector2:
	return position_out_area(Vector2.ZERO, _world_size, margin, region, ratio)


func _generate_code(length: int) -> String:
	var chars: String = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"							# 208,827,064,575 possible seeds (8 char)
	var code: String = ""														# _decode_base26("ZZZZZZZZ")

	for index in length:
		code += chars.substr(randi() % 26, 1)

	return code


func _encode_base26(input: int) -> String:										# from seed int to code string
	var char_map: String = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"							# reversible, unlike hash()

	if input == 0:
		return char_map[0]

	var output: String = ""
	var remainder: int = 0
	var map_size: int = char_map.length()

	while input > 0:
		remainder = input % map_size
		output += char_map[remainder]
		input = input / map_size

	return output


func _decode_base26(input: String) -> int:										# from code string to seed int
	var char_map: String = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

	var output: int = 0
	var map_size: int = char_map.length()

	var value: int
	var index: int = input.length()

	while index > 0:
		index -= 1
		value = char_map.find(input[index])
		output = (output * map_size) + value

	return output


var _pseudo_chance: Array[float] = [0.00000000000000,							# dota2.fandom.com/wiki/Random_Distribution
	0.00380165830355, 0.01474584478107, 0.03222091437309, 0.05570404294978,		# float has 14 reliable decimal digits of precision
	0.08474409185232, 0.11894919272540, 0.15798309812575, 0.20154741360775,
	0.24930699844016, 0.30210302534874, 0.36039785093317, 0.42264973081037,
	0.48112547833723, 0.57142857142857, 0.66666666666667, 0.75000000000000,
	0.82352941176471, 0.88888888888889, 0.94736842105263, 1.00000000000000]


func pseudo_chance(chance: int, repetitions: int = 0) -> float:					# increasing chance per repeat
	var chance_index: int = chance / 5 if chance % 5 == 0 else (chance / 5) + 1 # multiples of 5 (nearest 5 + 1)
	var chance_value: float = _pseudo_chance[chance_index]
	# print("%s * (%s + 1) = %s" % [chance_value, repetitions, chance_value * (repetitions + 1)])
	return chance_value * (repetitions + 1)


func pseudo_chance_test() -> void:
	var tries: int = 0
	var hits: int = 0
	for index in 1000:
		if pseudo_chance(25, tries) > randf():
			tries = 0
			hits += 1
		else:
			tries += 1
	print("%s out of 1000 = %s%%" % [hits, float(hits) / 1000 * 100])			# 254 out of 1000 = 25.4%


func _on_viewport_edit() -> void:
	_viewport_size = MyCore.viewport_size
	_viewport_half = _viewport_size * 0.5


func _on_world_edit() -> void:
	_world_size = MyCore.world_size
	_world_half = _world_size * 0.5


func _on_camera_zoom(_zoom: Vector2) -> void:
	_camera_zoom = _zoom
	_camera_size = _viewport_size / _camera_zoom
	_camera_half = _viewport_half / _camera_zoom
	_camera_position = _camera.position											# camera moves on zoom out (borders)


func _on_camera_move(_position: Vector2) -> void:
	_camera_position = _position
