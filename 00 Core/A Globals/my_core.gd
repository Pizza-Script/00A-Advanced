@tool
# class_name MyCore																# all about initial settings
extends Node

# NOTE: needs to be @tool for other @tool scripts
# NOTE: aspect = expand
	# 1.77778 (16 : 9) = default aspect
	# if greater = wider (9 height is maintained)
	# if lesser = taller (16 width is maintained)

	# use of CanvasLayer (no black bars)

# NOTE: Control in World CanvasLayer will not be resized
	# Control will remain in place

signal on_window_edit
signal on_viewport_edit
signal on_world_edit

static var window_size: Vector2 = Vector2(1280, 720)
	#  (160, 090) = [10 x 05.625]		[quarter]								# 16 : 9 [16px]
	#  (320, 180) = [20 x 11.250]		[half screen]
	#  (640, 360) = [40 x 22.500]		[default]
	# (1280, 720) = [80 x 45]			[full screen]

static var viewport_size: Vector2 = Vector2(640, 360)
	# Vector2(160, 90), Vector2(320, 180), Vector2(640, 360)
	# Vector2(1280, 720), Vector2(2560, 1440), Vector2(5120, 2880)
	# Vector2(1920, 1080), Vector2(3840, 2160), Vector2(5760, 3240)				# fullscreen only

static var world_size: Vector2 = Vector2(640, 360)

const TARGET_FPS: int = 240

var _root_window: Window


func _ready() -> void:
	if Engine.is_editor_hint() == true:
		return

	Engine.max_fps = TARGET_FPS
	_add_input_map()															# NOTE: will add WASD to auto-complete
	_sub_input_map()															# don't run on project load

	_root_window = get_window()
	_root_window.disable_3d = true
	_root_window.size_changed.connect(_on_window_resize)

	if viewport_size > window_size:
		printerr("ERROR: VIEWPORT_SIZE must be smaller than WINDOW_SIZE")

	if Engine.is_embedded_in_editor() == false:									# NOTE: Embedded window can't be resized
		DisplayServer.window_set_size(window_size)

	elif Vector2(_root_window.size) != window_size:								# window size
		ProjectSettings.set_setting("display/window/size/window_width_override", window_size.x)
		ProjectSettings.set_setting("display/window/size/window_height_override", window_size.y)
		ProjectSettings.save()

	if Vector2(_root_window.content_scale_size) != viewport_size:				# viewport size
		# camera base size (scale = 1.0)
		# smallest possible screen size (if scale_mode = integer)
		ProjectSettings.set_setting("display/window/size/viewport_width", viewport_size.x)
		ProjectSettings.set_setting("display/window/size/viewport_height", viewport_size.y)
		ProjectSettings.save()

	return																		# prevents "reload from disk" modal
	@warning_ignore("unreachable_code")

	ProjectSettings.set_setting("display/window/stretch/mode", "canvas_items")	# canvas_items / viewport
	ProjectSettings.set_setting("rendering/textures/canvas_textures/default_texture_filter", "0") 	# texture filter - nearest
	ProjectSettings.save()														# save

	# ProjectSettings.set_setting("display/window/stretch/scale_mode", "integer") # scale mode - integer
	# ProjectSettings.set_setting("display/window/size/resizable", false)		# resizable
	# ProjectSettings.set_setting("rendering/environment/defaults/default_clear_color", Color("3a4466")) # default clear color
	# ProjectSettings.set_setting("debug/gdscript/warnings/integer_division", "ignore")

	ProjectSettings.set_setting("display/window/stretch/aspect", "expand")


func change_world_size(new_world_size: Vector2) -> void:
	world_size = new_world_size
	on_world_edit.emit()


func _add_input_map() -> void:
	var keys: Dictionary[String, Array] = {
		"ui_up": 	[KEY_W],
		"ui_left": 	[KEY_A],
		"ui_down": 	[KEY_S],
		"ui_right": [KEY_D],
	}

	var my_event: InputEventKey
	for action in keys:
		if not InputMap.has_action(action):										# add action (if not existing)
			InputMap.add_action(action)

		for key in keys[action] as Array[Key]:									# add event to action
			my_event = InputEventKey.new()										# passed by reference
			my_event.keycode = key
			InputMap.action_add_event(action, my_event)


func _sub_input_map() -> void:													# seperated for twin-stick shooters
	var keys: Dictionary[String, Array] = {
		"ui_up": 	[KEY_UP],
		"ui_left": 	[KEY_LEFT],
		"ui_down": 	[KEY_DOWN],
		"ui_right": [KEY_RIGHT],
	}

	var my_event: InputEventKey
	for action in keys:
		if not InputMap.has_action(action):
			InputMap.add_action(action)

		for key in keys[action] as Array[Key]:
			my_event = InputEventKey.new()
			my_event.keycode = key
			InputMap.action_erase_event(action, my_event)


func _on_window_resize() -> void:
	window_size = _root_window.size
	viewport_size = get_viewport().get_visible_rect().size

	on_window_edit.emit()
	on_viewport_edit.emit()
