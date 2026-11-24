@tool
class_name MyGpuParticles2D														# 070 GPU Particles2D
extends EditorScript															# Ctrl + Shift + X

# ALVHZqRyHA00000000RNYG00000abJB 		[Default]
# 33MoSwTnQ5Zqw3QCVazyvvDQaMaaeUu5pQH   [Full]

const SEED: String = "ALVHZqRyHA00000000RNYG00000abJB"

var _material: ParticleProcessMaterial


func _run() -> void:
	var _script_path: String = get_script().get_path().get_base_dir() + "/"
	_material = ParticleProcessMaterial.new()
	_material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	_material.emission_sphere_radius = 16.0
	_material.gravity = Vector3.ZERO

	_build_data()
	load_data(SEED)

	ResourceSaver.save(_material, _script_path + "gpu_particles_2d.tres")
	print("%s created [%s]" % [_script_path + "gpu_particles_2d.tres", SEED])


### NOTE --- COPY HERE -- NOTE ###
var _properties: Array[String]

var _name_array: Array[String]
var _size_array: Array[int]
var _step_array: Array[float]

var _color_ramp_texture: GradientTexture1D = GradientTexture1D.new()
var _color_ramp_gradient: Gradient = Gradient.new()
var _color_ramp_init_texture: GradientTexture1D = GradientTexture1D.new()
var _color_ramp_init_gradient: Gradient = Gradient.new()
var _color_array: Array[Color] = [Color(1, 1, 1, 1), Color(0.1059, 0.1098, 0.2, 1.0),
		Color(0.827451, 0.152941, 0.203922, 1), Color(0.854902, 0.490196, 0.133333, 1),
		Color(0.901961, 0.854902, 0.160784, 1), Color(0.156863, 0.776471, 0.254902, 1),
		Color(0.176471, 0.576471, 0.866667, 1), Color(0.482353, 0.32549, 0.678431, 1)]
		# [Color("ffffff"), Color("1b1c33"), Color("d32734"), Color("da7d22"),
		# Color("e6da29"), Color("28c641"), Color("2d93dd"), Color("7b53ad")]

var _negative_names: Array[String] = ["angle_min", "angle_max", "velocity_pivot:x", "velocity_pivot:y",
	"angular_velocity_min", "angular_velocity_max", "orbit_velocity_min", "orbit_velocity_max",
	"radial_velocity_min", "radial_velocity_max", "linear_accel_min", "linear_accel_max",
	"radial_accel_min", "radial_accel_max", "tangential_accel_min", "tangential_accel_max","hue_variation_min",
	"hue_variation_max",] 	# 19 = 524,288

var _base_11_names: Array[String] = ["lifetime_randomness", "scale_min", "scale_max", "hue_variation_min", "hue_variation_max"]
var _base_11_reverse: Array[String]		# 5 = 177,155

var _base_21_names: Array[String] = ["orbit_velocity_min", "orbit_velocity_max", "radial_accel_min", "radial_accel_max",
	"tangential_accel_min", "tangential_accel_max", "damping_min", "damping_max"]
var _base_21_reverse: Array[String]		# 8 = 39,714,002,328

var _gravity_strength: float													# needs to be seperated
# var _gravity_angle: float														# to be loaded (0 * 0 = 0)


func _ready() -> void:
	_build_data()


func _build_data() -> void:
	_properties = [# name 			size, step
		"lifetime_randomness",		"2", "0.1",		# [0 - 1]		# 11

		"emission_sphere_radius",	"2", "1.0",		# [1 - 32]		# 31	+1 min
		"angle_min",				"2", "2.0",		# [0 - 180]		# 90	negative
		"angle_max",				"2", "2.0",		# [0 - 180]		# 90	negative
		"direction",				"2", "5.0",		# [0 - 360]		# 73	Vector2
		"velocity_pivot:x",			"2", "0.5",		# [0 - 32]		# 65	negative
		"velocity_pivot:y",			"2", "0.5",		# [0 - 32]		# 65	negative
		"spread",					"2", "1.0",		# [0 - 90]		# 91
		"initial_velocity_min",		"2", "2.0",		# [0 - 100]		# 51
		"initial_velocity_max",		"2", "2.0",		# [0 - 100]		# 51

		"angular_velocity_min",		"2", "2.0",		# [0 - 100]		# 51	negative
		"angular_velocity_max",		"2", "2.0",		# [0 - 100]		# 51	negative
		"orbit_velocity_min",		"2", "0.1",		# [0 - 2]		# 21	negative
		"orbit_velocity_max",		"2", "0.1",		# [0 - 2]		# 21	negative
		"radial_velocity_min",		"2", "2.0",		# [0 - 100]		# 51	negative
		"radial_velocity_max",		"2", "2.0",		# [0 - 100]		# 51	negative

		"gravity_strength",			"2", "2.0",		# [0 - 100]		# 51	Vector2
		"gravity_angle",			"2", "5.0",		# [0 - 360]		# 73	Vector2
		"linear_accel_min",			"2", "2.0",		# [0 - 100]		# 51	negative
		"linear_accel_max",			"2", "2.0",		# [0 - 100]		# 51	negative
		"radial_accel_min",			"2", "5.0",		# [0 - 100]		# 21	negative
		"radial_accel_max",			"2", "5.0",		# [0 - 100]		# 21	negative
		"tangential_accel_min",		"2", "5.0",		# [0 - 100]		# 21	negative
		"tangential_accel_max",		"2", "5.0",		# [0 - 100]		# 21	negative
		"damping_min",				"3", "5.0",		# [0 - 100]		# 21
		"damping_max",				"3", "5.0",		# [0 - 100]		# 21

		"scale_min",				"2", "0.5",		# [0.5 - 5]		# 10	+1 min
		"scale_max",				"2", "0.5",		# [0.5 - 5]		# 10	+1 min
		"color",					"1", "1.0",		# [8 Colors]
		"ramp_a", 					"1", "1.0",
		"ramp_b", 					"1", "1.0",
		"ramp_init_a", 				"1", "1.0",
		"ramp_init_b", 				"1", "1.0",
		"hue_variation_min",		"2", "0.10",	# [0 - 1.0]		# 11	negative
		"hue_variation_max",		"2", "0.10",	# [0 - 1.0]		# 11	negative
	]

	var index: int = 0
	while index < _properties.size():
		_name_array.append(_properties[index])
		_size_array.append(_properties[index + 1].to_int())
		_step_array.append(_properties[index + 2].to_float())
		index += 3

	_base_11_reverse = _base_11_names.duplicate() as Array[String]
	_base_11_reverse.reverse()

	_base_21_reverse = _base_21_names.duplicate() as Array[String]
	_base_21_reverse.reverse()


func save_data() -> String:
	print("--- --- --- save")

	var value: float = 0.0
	var final: float = 0.0
	var string: String = ""

	var base: int = 0
	var base_11: Array[float]
	var base_21: Array[float]

	var _sign: int = 0
	var sign_count: int = 0

	for index in _name_array.size():

		if _name_array[index] == "velocity_pivot:x":
			value = _material.velocity_pivot.x
			final = value / _step_array[index]

		elif _name_array[index] == "velocity_pivot:y":
			value = _material.velocity_pivot.y
			final = value / _step_array[index]

		elif _name_array[index] == "direction":									# Vector2
			var direction: Vector2 = Vector2(_material.direction.x, _material.direction.y)
			value = snappedf(rad_to_deg(direction.angle()), _step_array[index])
			value = wrapf(value, 0, 360)
			final = value / _step_array[index]

		elif _name_array[index] == "gravity_strength":
			var gravity: Vector2 = Vector2(_material.gravity.x, _material.gravity.y)
			value = gravity.length()
			final = value / _step_array[index]

		elif _name_array[index] == "gravity_angle":
			var gravity: Vector2 = Vector2(_material.gravity.x, _material.gravity.y)
			value = snappedf(rad_to_deg(gravity.angle()), _step_array[index])
			value = wrapf(value, 0, 360)
			final = value / _step_array[index]

		elif _name_array[index] == "color":										# color
			final = _color_array.find(_material.color)

		elif _name_array[index] == "ramp_a":
			if _material.color_ramp:
				var texture: = _material.color_ramp as GradientTexture1D
				final = _color_array.find(texture.gradient.get_color(0))

		elif _name_array[index] == "ramp_b":
			if _material.color_ramp:
				var texture: = _material.color_ramp as GradientTexture1D
				final = _color_array.find(texture.gradient.get_color(1))

		elif _name_array[index] == "ramp_init_a":
			if _material.color_initial_ramp:
				var texture: = _material.color_initial_ramp as GradientTexture1D
				final = _color_array.find(texture.gradient.get_color(0))

		elif _name_array[index] == "ramp_init_b":
			if _material.color_initial_ramp:
				var texture: = _material.color_initial_ramp as GradientTexture1D
				final = _color_array.find(texture.gradient.get_color(1))

		else:
			value = snappedf(_material.get(_name_array[index]), 0.01)
			final = value / _step_array[index]

			# print("[%s] %s - %s - %s" % [_name_array[index], value, _step_array[index], final])

		if _name_array[index] == "emission_sphere_radius":						# +1 min
			final -= 1.0
		elif _name_array[index] == "scale_min":
			final -= 1.0
		elif _name_array[index] == "scale_max":
			final -= 1.0

		if _negative_names.has(_name_array[index]):								# negative
			if signf(final) == -1.0:											# 0 if negative
				_sign = _sign | 0 << sign_count
				final = final * -1
			else:
				_sign = _sign | 1 << sign_count									# 1 if positive
			sign_count += 1

		if _base_11_names.has(_name_array[index]):								# reverse base 11
			base_11.append(final)
		elif _base_21_names.has(_name_array[index]):							# reverse base 21
			base_21.append(final)
		else:
			string += str(int(final)).lpad(_size_array[index], "0")

	print("[%02d] String  : %s" % [string.length(), string])

	base = 0
	for index in base_11.size():
		base = (base * 11) + int(base_11[index])
	string += str(base).lpad(6, "0")											# 5 = 177,155 possible combinations
	print("[06] Base 11 : %s" % str(base).lpad(6, "0"))

	base = 0
	for index in base_21.size():
		base = (base * 21) + int(base_21[index])
	string += str(base).lpad(11, "0")											# 8 = 39,714,002,328 possible combinations
	print("[11] Base 21 : %s" % str(base).lpad(11, "0"))

	string += str(_sign).lpad(6, "0")											# 19 signs - max 524,288
	print("[06] Sign    : %s" % str(_sign).lpad(6, "0"))

	print("[%02d] string  : %s" % [string.length(), string])
	string = _encode_int_to_string(string)
	print("[%02d] encode  : %s" % [string.length(), string])

	return string


func load_data(save_string: String = "") -> void:
	print("--- --- --- load")
	_material.particle_flag_disable_z = true

	save_string = _decode_string_to_int(save_string)
	print("[%02d] string  : %s" % [save_string.length(), save_string])

	var save_count: int = 0

	var saved: int = 0
	var value: float = 0.0

	var step_11: Array[float]
	var step_21: Array[float]

	var base: int = 0
	var base_value: int = 0

	for index in _name_array.size():
		if _base_11_names.has(_name_array[index]):
			step_11.append(_step_array[index])
			continue

		if _base_21_names.has(_name_array[index]):
			step_21.append(_step_array[index])
			continue

		saved = save_string.substr(save_count, _size_array[index]).to_int()

		if _name_array[index] == "emission_sphere_radius":						# +1 min
			saved += 1


		if _name_array[index] == "velocity_pivot:x":
			value = saved * _step_array[index]
			_material.velocity_pivot.x = value

		elif _name_array[index] == "velocity_pivot:y":
			value = saved * _step_array[index]
			_material.velocity_pivot.y = value

		elif _name_array[index] == "direction":									# Vector2
			value = saved * _step_array[index]
			var direction: Vector2 = Vector2.RIGHT.rotated(deg_to_rad(value))
			_material.direction = Vector3(direction.x, direction.y, 0.0)

		elif _name_array[index] == "gravity_strength":
			value = saved * _step_array[index]
			_gravity_strength = value

			# var direction: Vector2 = Vector2(_material.gravity.x, _material.gravity.y).normalized()
			# var gravity: Vector2 = direction.normalized() * value
			# _material.gravity = Vector3(gravity.x, gravity.y, 0.0)

		elif _name_array[index] == "gravity_angle":
			value = saved * _step_array[index]

			# var gravity: Vector2 = Vector2(_material.gravity.x, _material.gravity.y)
			# var gravity_strength: float = gravity.length()

			var gravity: Vector2 = Vector2.RIGHT.rotated(deg_to_rad(value)) * _gravity_strength
			_material.gravity = Vector3(gravity.x, gravity.y, 0.0)

		elif _name_array[index] == "color":										# color
			_material.color =  _color_array[saved]

		elif _name_array[index] == "ramp_a":
			if _color_ramp_texture.gradient == null:
				_color_ramp_texture.gradient = _color_ramp_gradient
			_color_ramp_gradient.set_color(0, _color_array[saved])
			_material.color_ramp = _color_ramp_texture

		elif _name_array[index] == "ramp_b":
			if _color_ramp_texture.gradient == null:
				_color_ramp_texture.gradient = _color_ramp_gradient
			_color_ramp_gradient.set_color(1, _color_array[saved])
			_material.color_ramp = _color_ramp_texture

		elif _name_array[index] == "ramp_init_a":
			if _color_ramp_init_texture.gradient == null:
				_color_ramp_init_texture.gradient = _color_ramp_init_gradient
			_color_ramp_init_gradient.set_color(0, _color_array[saved])
			_material.color_initial_ramp = _color_ramp_init_texture

		elif _name_array[index] == "ramp_init_b":
			if _color_ramp_init_texture.gradient == null:
				_color_ramp_init_texture.gradient = _color_ramp_init_gradient
			_color_ramp_init_gradient.set_color(1, _color_array[saved])
			_material.color_initial_ramp = _color_ramp_init_texture

		else:
			value = saved * _step_array[index]
			_material.set(_name_array[index], value)

		save_count += _size_array[index]

	print("[%02d] String  : %s" % [save_count, save_string.substr(0, save_count)])

	base = save_string.substr(save_count, 6).to_int()						# 177,155 possible combinations
	save_count += 6
	print("[06] Base 11 : %s" % base)

	step_11.reverse()
	for index in _base_11_reverse.size():
		base_value = base % 11

		if _base_11_reverse[index] == "scale_min":						# +1 min
			base_value += 1
		elif _base_11_reverse[index] == "scale_max":
			base_value += 1

		value = base_value * step_11[index]
		_material.set(_base_11_reverse[index], value)

		base = base / 11


	base = save_string.substr(save_count, 11).to_int()					# 8 = 39,714,002,328 possible combinations
	save_count += 11
	print("[11] Base 21 : %s" % base)

	step_21.reverse()
	for index in _base_21_reverse.size():
		base_value = base % 21

		value = base_value * step_21[index]
		_material.set(_base_21_reverse[index], value)

		base = base / 21


	var negative: int = save_string.substr(save_count, 6).to_int()				# 19 signs - max 524,288
	save_count += 2

	print("[06] Sign    : %s" % negative)

	var negative_value: bool
	var sign_value: float = 0.0
	for index in _negative_names.size():
		negative_value = negative & 1 << index
		if negative_value == false:

			if _negative_names[index] == "velocity_pivot:x":
				_material.velocity_pivot.x *= -1
			elif _negative_names[index] == "velocity_pivot:y":
				_material.velocity_pivot.y *= -1
			else:
				sign_value = snappedf(_material.get(_negative_names[index]), 0.01)	# get value
				_material.set(_negative_names[index], sign_value * -1)


func _encode_int_to_string(input: String) -> String:
	var output: String = ""
	var chunk: int

	chunk = input.substr(00, 16).to_int()
	output += _int_encode_base62(chunk).rpad(09, "0")

	chunk = input.substr(16, 16).to_int()										# 16 + 16 + 16 + 14 = 62
	output += _int_encode_base62(chunk).rpad(09, "0")							# 09 + 09 + 09 + 08 = 35

	chunk = input.substr(32, 16).to_int()										# 17 + 17 + 17 + 12 = 62
	output += _int_encode_base62(chunk).rpad(09, "0")							# 10 + 10 + 10 + 07 = 37

	chunk = input.substr(48, 14).to_int()										# 18 + 18 + 18 + 08 = 62
	output += _int_encode_base62(chunk)											# 11 + 11 + 11 + 05 = 38

	return output


func _decode_string_to_int(input: String) -> String:
	var output: String = ""
	var chunk: String
	var value: int

	chunk = input.substr(00, 09)
	chunk = chunk.replace("0", "")
	value = _int_decode_base62(chunk)
	output += str(value).lpad(16, "0")

	chunk = input.substr(09, 09)
	chunk = chunk.replace("0", "")
	value = _int_decode_base62(chunk)
	output += str(value).lpad(16, "0")

	chunk = input.substr(18, 09)
	chunk = chunk.replace("0", "")
	value = _int_decode_base62(chunk)
	output += str(value).lpad(16, "0")

	chunk = input.substr(27, 08)
	chunk = chunk.replace("0", "")
	value = _int_decode_base62(chunk)
	output += str(value).lpad(14, "0")

	return output


func _int_encode_base62(input: int) -> String:
	var char_map: String = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz123456789"

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


func _int_decode_base62(input: String) -> int:
	var char_map: String = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz123456789"

	var output: int = 0
	var map_size: int = char_map.length()

	var value: int
	var index: int = input.length()

	while index > 0:
		index -= 1
		value = char_map.find(input[index])
		output = (output * map_size) + value

	return output
