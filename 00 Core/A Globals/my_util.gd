# class_name MyUtil
extends Node

# MyUtil.array_average(_array_int)
# MyUtil.array_average_f(_array_float)

# MyUtil.add_comma()
# MyUtil.add_comma_f()

# MyUtil.add_notation(int)

var _is_logs_active: bool = false
	# MyUtil.add_log(_string)

var _is_debug_active: bool = false
	# Timer
	# FPS & SPD
	# KEY +/- time_scale
	# KEY_F fullscreen

var _is_mouse_server: bool = false
	# PhysicsServer2D.area_set_collision_mask(_unit_rid, 1 << MyNode.Layer.MOUSE)

const MAX_INT: int = 9_223_372_036_854_775_807									# max possible int

const GAME_NOTATION: Array[String] = ["k", "m", "b", "t", "q", "qi", "s", "sp", # en.wikipedia.org/wiki/Order_of_magnitude
		"aa", "ab", "ac", "ad", "ae", "af", "ag", "ah", "ai", "aj", "ak",
		"al", "am",	"an", "ao", "ap", "aq", "ar", "as", "at", "au", "av",
		"aw", "ax",	"ay", "az"]

var timer: Timer = Timer.new()
var timer_total: int
var timer_secs: int
var timer_mins: int

var _time_mult: float

var _log_path: String															# TODO: should stay ?
var _log_file: FileAccess

var _mouse_rid: RID
var _mouse_radius: float = 64.0
var _mouse_shape: RID = PhysicsServer2D.circle_shape_create()
var _mouse_position: Vector2

var _viewport: Viewport


func _ready() -> void:
	if _is_logs_active == true:
		_log_path = "user://" + _get_time() + ".log"
		_log_file = FileAccess.open(_log_path, FileAccess.WRITE)

	set_process_unhandled_key_input(_is_debug_active)
	if _is_debug_active == true:
		add_child(timer)
		timer.start(1.0)
		timer.timeout.connect(_on_timer_timeout)

	set_process_unhandled_input(_is_mouse_server)
	if _is_mouse_server == true:
		PhysicsServer2D.shape_set_data(_mouse_shape, _mouse_radius)

		_mouse_rid = PhysicsServer2D.area_create()
		PhysicsServer2D.area_add_shape(_mouse_rid, _mouse_shape)					# multiple areas can re-use single shape
		PhysicsServer2D.area_set_space(_mouse_rid, get_viewport().find_world_2d().space) # needed for query & callback
		PhysicsServer2D.area_set_collision_mask(_mouse_rid, 0)
		PhysicsServer2D.area_set_collision_layer(_mouse_rid, 1 << MyNode.Layer.MOUSE)
		PhysicsServer2D.area_set_monitorable(_mouse_rid, true)					# needed for callback of other server area

		_viewport = get_viewport()

	MyDraw.draw.connect(_on_draw)


func _on_draw() -> void:
	if _is_debug_active == true:
		timer_mins = timer_total / 60
		timer_secs = timer_total % 60
		MyDraw.text_auto("%02d:%02d" % [timer_mins, timer_secs], MyDraw.TL)

		MyDraw.text_auto("FPS: %02d" % Engine.get_frames_per_second(), MyDraw.TL)
		MyDraw.text_auto("SPD:x%01d" % [1 + (log(Engine.time_scale) / log(2))], MyDraw.TL)

	if _is_mouse_server == true:
		MyDraw.circle(_mouse_position, _mouse_radius)


func _unhandled_key_input(event: InputEvent) -> void:
	var key_event: = event as InputEventKey
	var key: Key = key_event.keycode

	if key_event.pressed == false:												# on press down only
		return

	if key == KEY_PLUS || key == KEY_KP_ADD || key == KEY_EQUAL:
		if Engine.time_scale < 128.0:
			_time_mult += 1.0
			Engine.time_scale = pow(2.0, _time_mult)
			MyDraw.queue_redraw()

	if key == KEY_MINUS || key == KEY_KP_SUBTRACT:
		if Engine.time_scale > 1.0:
			_time_mult -= 1.0
			Engine.time_scale = pow(2.0, _time_mult)
			MyDraw.queue_redraw()

	if key_event.echo == true:													# trigger only once
		return

	if key == KEY_F:															# FULLSCREEN
		if Engine.is_embedded_in_editor() == true:
			print("can't full screen, window is embedded")
			return
			# [github.com/godotengine/godot/issues/103171] ERROR: Embedded window only supports Windowed mode
			# [github.com/godotengine/godot/issues/103428] allow fullscreen when embedded
			# [github.com/godotengine/godot-proposals/issues/12856] change embed on code

		if DisplayServer.window_get_mode() != DisplayServer.WINDOW_MODE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		_mouse_position = _viewport.get_canvas_transform().affine_inverse() * _viewport.get_mouse_position()
		PhysicsServer2D.area_set_transform(_mouse_rid, Transform2D(0, _mouse_position))
		MyDraw.queue_redraw()


func _get_time() -> String:
	var unix_time: int = int(Time.get_unix_time_from_system())
	var unix: Dictionary = Time.get_datetime_dict_from_unix_time(unix_time)
	var bias: int = Time.get_time_zone_from_system()["bias"] / 60
	return "%s-%02d-%02d %02d-%02d" % [unix["year"], unix["month"], unix["day"], unix["hour"] + bias, unix["minute"]]


func add_log(line: String) -> void:
	if _is_logs_active == true:
		_log_file.store_line(line)


func array_average(my_array: Array[int]) -> int:
	if my_array.is_empty():
		return 0
	var func_sum: Callable = func(sum: int, num: int): return sum + num
	var total: int = my_array.reduce(func_sum)
	return total / my_array.size()
	# return my_array.reduce(func(sum: int, num: int): return sum + num) / my_array.size()


func array_average_f(my_array: Array[float]) -> float:
	if my_array.is_empty():
		return 0.0
	var func_sum: Callable = func(sum: float, num: float): return sum + num
	var total: float = my_array.reduce(func_sum)
	return total / my_array.size()
	# return my_array.reduce(func(sum: float, num: float): return sum + num) / my_array.size()


func add_comma(num: int) -> String:
	var output: String = ""
	while num > 999:
		output = ",%03d%s" % [num % 1000, output]
		num /= 1000
	return "%s%s" % [num, output]


func add_comma_f(num: float, pad: int = 2) -> String:
	var output: String = ""
	var num_int: int = int(num)
	while num_int > 999.0:
		output = ",%03d%s" % [num_int % 1000, output]
		num_int /= 1000

	var num_mod: String = ""
	if is_finite(num) && num < 1_000_000_000:
		num_mod = str(fmod(num, 1.0))
		if num_mod == "0.0":
			num_mod = ""
		else:
			num_mod = num_mod.substr(1, 1 + pad)

	return "%s%s%s" % [num_int, output, num_mod]


func add_notation(number: int) -> String:
	if number < 1_000:															# 999
		return "%d" % [number]
	elif number < 10_000:														# 9,999 (max 4 chars + comma)
		return str(number / 1_000) + "," + str(number).substr(1, 3)

	var length: int = str(number).length()
	var notation: int = (length - 4) / 3										# notation based on num length

	var divisor: float = pow(10, (notation + 1) * 3)							# 1000000.0
	var quotient: float = number / divisor										# 1.996273

	var num_int: String = str(int(quotient))									# 1
	var num_mod: String = str(fmod(quotient, 1.0))								# 0.996273
	if num_mod == "0.0":
		num_mod = ""
	else:
		num_mod = num_mod.substr(1, 3)											# 0.99

	return num_int + num_mod + " " + GAME_NOTATION[notation]					# .to_upper()


func _on_timer_timeout() -> void:
	timer_total += 1
	MyDraw.queue_redraw()
