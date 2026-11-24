@tool
class_name MyFastNoiseLite														# 041 FastNoiseLite v2
extends EditorScript															# Ctrl + Shift + X

# WARNING: FastNoiseLite gets cached in the Inspector
# to reload, delete the file, un-focus on the Inspector
# then "Reload Current Project"

# Um877nHVIPIlFmwLNFkELJ		[Default]
# FgQrmFRXhdmVzpWjnP6M3R		[Full]

const SEED: String = "DcOsH33UafUzlxT4EOGb87E"

var _script_path: String
var _noise_texture: NoiseTexture2D


func _run() -> void:
	_script_path = get_script().get_path().get_base_dir() + "/"
	_noise_texture = NoiseTexture2D.new()
	_noise_texture.noise = FastNoiseLite.new()

	_build_data()
	load_data(SEED)

	ResourceSaver.save(_noise_texture, _script_path + "fast_noise_lite.tres")
	print("%s created [%s]" % [_script_path + "fast_noise_lite.tres", SEED])


### NOTE --- COPY HERE -- NOTE ###
var _fast_noise_lite: FastNoiseLite

var _properties: Array[String]

var _bool_array: Array[String]

var _float_array: Array[String]
var _float_count: Array[int]
var _float_snap: Array[float]

var _int_array: Array[String]
var _int_count: Array[int]


func _ready() -> void:
	_build_data()


func _build_data() -> void:
	_fast_noise_lite = _noise_texture.noise as FastNoiseLite

	_properties = [                                     # type - name - count - snap
		"TYPE_BOOL",  "invert",							# 1
		"TYPE_BOOL",  "in_3d_space",					# 1
		"TYPE_BOOL",  "seamless",						# 1
		"TYPE_FLOAT", "seamless_blend_skirt",        	"2", "0.05",		# 20
		"TYPE_BOOL",  "as_normal_map",					# 1
		"TYPE_INT",   "bump_strength",      			"2",
		"TYPE_BOOL",  "normalize",						# 1

		"TYPE_INT",   "noise_type",         			"1",
		"TYPE_FLOAT", "frequency",          			"2", "0.01",		# 99		# 0.01 minimum
		"TYPE_INT",   "seed",               			"7",

		"TYPE_INT",   "fractal_type",					"1",
		"TYPE_INT",   "fractal_octaves",            	"1",							# 1 minimum
		"TYPE_INT",   "fractal_lacunarity",         	"3",
		"TYPE_FLOAT", "fractal_gain",               	"2", "0.10",		# 50
		"TYPE_FLOAT", "fractal_weighted_strength",  	"2", "0.05",		# 20
		"TYPE_INT",   "fractal_ping_pong_strength", 	"3",

		"TYPE_INT",   "cellular_distance_function", 	"1",
		"TYPE_FLOAT", "cellular_jitter",            	"2", "0.50",		# 20
		"TYPE_INT",   "cellular_return_type",       	"1",

		"TYPE_BOOL",  "domain_warp_enabled",			# 1
		"TYPE_INT",   "domain_warp_type",               "1",
		"TYPE_INT",   "domain_warp_amplitude",          "3",
		"TYPE_FLOAT", "domain_warp_frequency",          "2", "0.05",		# 20
		"TYPE_INT",   "domain_warp_fractal_type",       "1",
		"TYPE_INT",   "domain_warp_fractal_octaves",    "1",							# 1 minimum
		"TYPE_INT",   "domain_warp_fractal_lacunarity", "3",
		"TYPE_FLOAT", "domain_warp_fractal_gain",       "2", "0.10",		# 50
	]

	_bool_array.clear()
	_float_array.clear()
	_float_count.clear()
	_float_snap.clear()
	_int_array.clear()
	_int_count.clear()

	var index: int = 0
	while index < _properties.size():

		match _properties[index]:

			"TYPE_BOOL":
				_bool_array.append(_properties[index + 1])
				index += 2

			"TYPE_FLOAT":
				_float_array.append(_properties[index + 1])
				_float_count.append(_properties[index + 2].to_int())
				_float_snap.append(_properties[index + 3].to_float())
				index += 4

			"TYPE_INT":
				_int_array.append(_properties[index + 1])
				_int_count.append(_properties[index + 2].to_int())
				index += 3


func save_data() -> String:

	# BOOL
	var bool_value: int = 0
	var bool_final: int = 0
	var bool_string: String = ""

	for index in _bool_array.size():
		if _bool_array[index] == "invert":
			bool_value = int(_noise_texture.invert)
		elif _bool_array[index] == "in_3d_space":
			bool_value = int(_noise_texture.in_3d_space)
		elif _bool_array[index] == "seamless":
			bool_value = int(_noise_texture.seamless)
		elif _bool_array[index] == "as_normal_map":
			bool_value = int(_noise_texture.as_normal_map)
		elif _bool_array[index] == "normalize":
			bool_value = int(_noise_texture.normalize)
		else:
			bool_value = int(_fast_noise_lite.get(_bool_array[index]))

		bool_final = bool_final | bool_value << index

	bool_string = str(bool_final).lpad(2, "0")									# 6 bool - 63 max


	# FLOAT
	var float_value: float = 0.0
	var float_final: float = 0.0
	var float_string: String = ""

	var float_base_array: Array[float]

	for index in _float_array.size():											# reverse base 99

		if _float_array[index] == "seamless_blend_skirt":
			float_value = snappedf(_noise_texture.seamless_blend_skirt, 0.01)	# snap needed (value = 0.1111)
		else:
			float_value = snappedf(_fast_noise_lite.get(_float_array[index]), 0.01)	# 0.5

		float_final = float_value / _float_snap[index]							# 5.0 = 0.5 / 0.1

		if _float_array[index] == "frequency":									# 0.01 minimum
			float_final -= 1.0

		if _float_array[index] == "seamless_blend_skirt":						# properties w/ 21 possible values
			float_base_array.append(float_final)
		elif _float_array[index] == "fractal_weighted_strength":
			float_base_array.append(float_final)
		elif _float_array[index] == "cellular_jitter":
			float_base_array.append(float_final)
		elif _float_array[index] == "domain_warp_frequency":
			float_base_array.append(float_final)
		else:
			float_string += str(int(float_final)).lpad(_float_count[index], "0") # "base" values (non 21 possible values)

	var float_base: int = 0
	var float_base_size: int = 21												# 21 possible values
	for index in float_base_array.size():
		float_base = (float_base * float_base_size) + int(float_base_array[index]) # decode	(chars to value)
	float_string += str(float_base).lpad(6, "0")								# 204,204 possible combinations


	# INT
	var int_value: int = 0
	var int_string: String = ""

	var int_base_array: Array[int]

	for index in _int_array.size():
		if _int_array[index] == "bump_strength":
			int_value = int(_noise_texture.bump_strength)
		else:
			int_value = _fast_noise_lite.get(_int_array[index])

		if _int_array[index] == "fractal_octaves":								# 1 minimum
			int_value -= 1
		elif _int_array[index] == "domain_warp_fractal_octaves":
			int_value -= 1

		if _int_array[index] == "fractal_lacunarity":							# reverse base 101
			int_base_array.append(int_value)
		elif _int_array[index] == "fractal_ping_pong_strength":
			int_base_array.append(int_value)
		elif _int_array[index] == "domain_warp_amplitude":
			int_base_array.append(int_value)
		elif _int_array[index] == "domain_warp_fractal_lacunarity":
			int_base_array.append(int_value)
		else:
			int_string += str(int_value).lpad(_int_count[index], "0")

	var int_base: int = 0
	var int_size: int = 101
	for index in int_base_array.size():
		int_base = (int_base * int_size) + int_base_array[index]
	int_string += str(int_base).lpad(9, "0")									# 105,101,004 possible combinations

	var save_string: String = bool_string + float_string + int_string
	save_string = _encode_int_to_string(save_string)
	return save_string


func load_data(save_string: String) -> void:
	save_string = _decode_string_to_int(save_string)

	var save_count: int = 2														# 6 bool - 63 max

	# BOOL
	var bool_save: int = save_string.substr(0, 2).to_int()
	var bool_value: bool

	for index in _bool_array.size():
		bool_value = bool_save & 1 << index

		if _bool_array[index] == "invert":
			_noise_texture.invert = bool_value
		elif _bool_array[index] == "in_3d_space":
			_noise_texture.in_3d_space = bool_value
		elif _bool_array[index] == "seamless":
			_noise_texture.seamless = bool_value
		elif _bool_array[index] == "as_normal_map":
			_noise_texture.as_normal_map = bool_value
		elif _bool_array[index] == "normalize":
			_noise_texture.normalize = bool_value
		else:
			_fast_noise_lite.set(_bool_array[index], bool_value)


	# FLOAT
	var float_saved: int = 0
	var float_value: float = 0.0

	# "frequency", "fractal_gain", "domain_warp_fractal_gain",
	var float_base_array: Array[String] = ["seamless_blend_skirt", "fractal_weighted_strength", "cellular_jitter", "domain_warp_frequency"]
	var float_snap_array: Array[float]
	var float_base: int = 0
	var float_base_size: int = 21
	var float_base_value: int = 0

	for index in _float_array.size():
		if float_base_array.has(_float_array[index]):							# skip "base" values
			float_snap_array.append(_float_snap[index])
			continue

		float_saved = save_string.substr(save_count, _float_count[index]).to_int()
		float_value = _float_snap[index] * float_saved

		save_count += _float_count[index]

		if _float_array[index] == "frequency":
			_fast_noise_lite.frequency = float_value + 0.01
		else:
			_fast_noise_lite.set(_float_array[index], float_value)

	float_base = save_string.substr(save_count, 6).to_int()						# 204,204 possible combinations
	save_count += 6

	float_base_array.reverse()													# calculate in reverse
	float_snap_array.reverse()
	for index in float_base_array.size():
		float_base_value = float_base % float_base_size							# encode (value to chars)
		float_value = float_snap_array[index] * float_base_value

		if float_base_array[index] == "seamless_blend_skirt":
			_noise_texture.seamless_blend_skirt = float_value
		else:
			_fast_noise_lite.set(float_base_array[index], float_value)

		float_base = float_base / float_base_size


	# INT
	var int_value: int = 0

	var int_base_array: Array[String] = ["fractal_lacunarity", "fractal_ping_pong_strength", "domain_warp_amplitude", "domain_warp_fractal_lacunarity"]
	var int_base: int = 0
	var int_base_size: int = 101
	var int_base_value: int = 0

	for index in _int_array.size():
		if int_base_array.has(_int_array[index]):
			continue

		int_value = save_string.substr(save_count, _int_count[index]).to_int()
		save_count += _int_count[index]

		if _int_array[index] == "bump_strength":
			_noise_texture.bump_strength = int_value
		if _int_array[index] == "fractal_octaves":
			_fast_noise_lite.fractal_octaves = int_value + 1
		elif _int_array[index] == "domain_warp_fractal_octaves":
			_fast_noise_lite.domain_warp_fractal_octaves = int_value + 1
		else:
			_fast_noise_lite.set(_int_array[index], int_value)

	int_base = save_string.substr(save_count, 9).to_int()						# 105,101,004 possible combinations
	save_count += 9

	int_base_array.reverse()
	for index in int_base_array.size():
		int_base_value = int_base % int_base_size
		_fast_noise_lite.set(int_base_array[index], int_base_value)
		int_base = int_base / int_base_size


func _encode_int_to_string(input: String) -> String:
	var output: String = ""
	var chunk: int

	chunk = input.substr(00, 16).to_int()										# 16 + 16 + 08 = 40
	output += _int_encode_base62(chunk).rpad(09, "0")							# 09 + 09 + 05 = 23

	chunk = input.substr(16, 16).to_int()
	output += _int_encode_base62(chunk).rpad(09, "0")

	chunk = input.substr(32, 08).to_int()
	output += _int_encode_base62(chunk)

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

	chunk = input.substr(18, 05)
	chunk = chunk.replace("0", "")
	value = _int_decode_base62(chunk)
	output += str(value).lpad(08, "0")

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
