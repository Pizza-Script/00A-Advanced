class_name DrawView
extends Node

var _is_vsync: bool = true
var _is_fullscreen: bool = false

var _viewport: Viewport

var _window_size: Vector2
var _window_half: Vector2

var _viewport_size: Vector2
var _viewport_half: Vector2

var _world_size: Vector2
var _world_half: Vector2

var _camera: MyCamera
var _camera_zoom: Vector2
var _camera_size: Vector2
var _camera_half: Vector2
var _camera_position: Vector2													# to handle drag

var _mouse_global_pos: Vector2
var _mouse_viewport_pos: Vector2


func _ready() -> void:
	MyCore.on_window_edit.connect(_on_window_edit)
	MyCore.on_viewport_edit.connect(_on_viewport_edit)
	MyCore.on_world_edit.connect(_on_world_edit)

	_viewport = get_tree().root.get_viewport()

	_window_size = MyCore.window_size
	_window_half = MyCore.window_size * 0.5

	_viewport_size = MyCore.viewport_size
	_viewport_half = MyCore.viewport_size * 0.5

	_world_size = MyCore.world_size
	_world_half = _world_size * 0.5

	_camera = get_viewport().get_camera_2d()
	if _camera == null:															# for scenes w/o Camera2D (i.e. F6)
		return

	_camera.on_zoom.connect(_on_camera_zoom)
	_camera.on_move.connect(_on_camera_move)

	_camera_zoom = _camera.zoom
	_camera_size = _viewport_size / _camera_zoom
	_camera_half = _viewport_half / _camera_zoom
	_camera_position = _camera.position

	MyDraw.draw.connect(_on_draw)
	MyDraw.queue_redraw()


func _process(_delta: float) -> void:
	MyDraw.queue_redraw()														# for FPS


func _on_draw() -> void:
	MyDraw.circle_camera(Vector2(0, 0), 8.0)									# TL
	MyDraw.circle_camera(Vector2(_viewport_size.x, 0), 8.0)						# TR
	MyDraw.circle_camera(Vector2(0, _viewport_size.y), 8.0)						# BL
	MyDraw.circle_camera(Vector2(_viewport_size.x, _viewport_size.y), 8.0)		# BR
	MyDraw.circle_camera(_viewport_half, 8.0)									# CENTER

	MyDraw.text_auto_camera("FPS   : %02d" % [Engine.get_frames_per_second()], MyDraw.TL)
	MyDraw.text_auto_camera("VSYNC : %s" % [str(_is_vsync).to_upper()], MyDraw.TL)

	# BL - bottom to top
	MyDraw.text_auto_camera("STRETCH SCALE MODE : %s" % [ProjectSettings.get_setting("display/window/stretch/scale_mode").to_upper()], MyDraw.BL)
	MyDraw.text_auto_camera("STRETCH ASPECT     : %s" % [ProjectSettings.get_setting("display/window/stretch/aspect").to_upper()], MyDraw.BL)
	MyDraw.text_auto_space_camera(1, MyDraw.BL)

	MyDraw.text_auto_camera("WORLD SIZE    : %04d x %04d" % [_world_size.x, _world_size.y], MyDraw.BL)
	MyDraw.text_auto_camera("VIEWPORT SIZE : %04d x %04d" % [_viewport_size.x, _viewport_size.y], MyDraw.BL)
	MyDraw.text_auto_camera("WINDOW SIZE   : %04d x %04d" % [_window_size.x, _window_size.y], MyDraw.BL)
	MyDraw.text_auto_camera("ASPECT RATIO  : %03.5f" % [MyCore.window_size.x /  MyCore.window_size.y], MyDraw.BL)
	MyDraw.text_auto_space_camera(1, MyDraw.BL)

	MyDraw.text_auto_camera("CAMERA ZOOM : x%s" % [str(_camera_zoom.x).to_upper()], MyDraw.BL)
	MyDraw.text_auto_camera("CAMERA SIZE : %04d x %04d" % [_camera_size.x, _camera_size.y], MyDraw.BL)
	MyDraw.text_auto_camera("CAMERA HALF : %04d x %04d" % [_camera_half.x, _camera_half.y], MyDraw.BL)
	MyDraw.text_auto_camera("CAMERA POS  : %04d x %04d" % [_camera_position.x, _camera_position.y], MyDraw.BL)
	MyDraw.text_auto_space_camera(1, MyDraw.BL)

	MyDraw.text_auto_camera("MOUSE VIEWPORT POS : %04d x %04d" % [_mouse_viewport_pos.x, _mouse_viewport_pos.y], MyDraw.BL)
	MyDraw.text_auto_camera("MOUSE GLOBAL POS   : %04d x %04d" % [_mouse_global_pos.x, _mouse_global_pos.y], MyDraw.BL)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		_mouse_global_pos = _camera.get_global_mouse_position()
		_mouse_viewport_pos = (_mouse_global_pos - (_camera_position - _camera_half)) * _camera_zoom


func _unhandled_key_input(event: InputEvent) -> void:
	var key_event: = event as InputEventKey
	var key: Key = key_event.keycode

	if key_event.pressed == false:
		return

	if key_event.echo == true:
		return

	if key == KEY_T:
		_is_vsync = !_is_vsync
		if _is_vsync == true:
			DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
		elif _is_vsync == false:
			DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)

	if key == KEY_F:
		_is_fullscreen = !_is_fullscreen
		if _is_fullscreen == true:												# must disable "Game Embed on Next Play"
			DisplayServer.window_set_mode(DisplayServer.WindowMode.WINDOW_MODE_FULLSCREEN)
		elif _is_fullscreen == false:
			DisplayServer.window_set_mode(DisplayServer.WindowMode.WINDOW_MODE_WINDOWED)


func _on_window_edit() -> void:
	_window_size = MyCore.window_size
	_window_half = MyCore.window_size * 0.5
	MyDraw.queue_redraw()


func _on_viewport_edit() -> void:
	_viewport_size = MyCore.viewport_size
	_viewport_half = MyCore.viewport_size * 0.5


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

	_mouse_global_pos = _camera.get_global_mouse_position()
	_mouse_viewport_pos = (_mouse_global_pos - (_camera_position - _camera_half)) * _camera_zoom
