class_name MyCamera
extends Camera2D

@warning_ignore("unused_signal")
signal on_move(my_position: Vector2)
signal on_zoom(zoom_value: Vector2)

@export var _start_centered: bool = true
@export var _start_position: Vector2 = Vector2(0.0, 0.0)

@export_range(0, 10) var _zoom_in_limit: int = 0
@export_range(-10, 0) var _zoom_out_limit: int = 0
@export var _zoom_start: int = 0												# start game zoomed in

@export var _zoom_smooth: bool = false
@export var _zoom_smooth_time: float = 0.15

@export var _filter_enabled: bool = false
@export var _filter_index: int = 0

var _world_size: Vector2 = MyCore.world_size									# different world size
var _world_half: Vector2 = _world_size * 0.5

var _zoom_index: int
var _zoom_tween: Tween

@onready var _viewport: Viewport = get_viewport()


func _ready() -> void:
	anchor_mode = Camera2D.ANCHOR_MODE_DRAG_CENTER								# camera.position = center of screen
	# anchor_mode = Camera2D.ANCHOR_MODE_FIXED_TOP_LEFT							# camera.position = top-left

	if _start_centered == true:
		position = _world_half
	else:
		position = _start_position

	_zoom_index = _zoom_start
	_zoom_apply()

	if _zoom_start > _zoom_in_limit:											# prevent confusion when limit is 0
		_zoom_in_limit = _zoom_start

	if _zoom_start < _zoom_out_limit:
		_zoom_out_limit = _zoom_start


func _unhandled_key_input(event: InputEvent) -> void:
	var key_event: = event as InputEventKey
	var key: Key = key_event.keycode

	if key_event.pressed == false:
		return

	if key_event.echo == true:
		return

	if key == KEY_PLUS || key == KEY_KP_ADD || key == KEY_EQUAL:
		_zoom_in()

	elif key == KEY_MINUS || key == KEY_KP_SUBTRACT:
		_zoom_out()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse_event: = event as InputEventMouseButton

		if mouse_event.pressed == false:										# on press down only
			return

		if mouse_event.button_index == MOUSE_BUTTON_WHEEL_UP:					# zoom in
			_zoom_in()

		elif mouse_event.button_index == MOUSE_BUTTON_WHEEL_DOWN:				# zoom out
			_zoom_out()


func _zoom_in() -> void:
	if _zoom_tween != null && _zoom_tween.is_valid() == true:					# wait for zoom_smooth to end
		return

	if _zoom_index == _zoom_in_limit:
		return

	_zoom_index += 1
	_zoom_apply()


func _zoom_out() -> void:
	if _zoom_tween != null && _zoom_tween.is_valid() == true:					# wait for zoom_smooth to end
		return

	if _zoom_index == _zoom_out_limit:
		return

	_zoom_index -= 1
	_zoom_apply()


func _zoom_apply() -> void:
	var zoom_float: float = 2.0 ** _zoom_index									# [  -2,  -1,   0,   1,   2]
	var zoom_v2: Vector2 = Vector2(zoom_float, zoom_float)						# [0.25, 0.5, 1.0, 2.0, 4.0]

	if _zoom_smooth == false:
		_zoom_tween = create_tween()
		_zoom_tween.tween_callback(func(): zoom = zoom_v2)
		_zoom_tween.tween_callback(func(): on_zoom.emit(zoom_v2))
		_zoom_tween.tween_interval(0.07)										# prevent very quick zooms

	elif _zoom_smooth == true:
		_zoom_tween = create_tween()
		_zoom_tween.tween_property(self, "zoom", zoom_v2, _zoom_smooth_time)
		_zoom_tween.tween_callback(func(): on_zoom.emit(zoom_v2))

	_zoom_filter()


func _zoom_filter() -> void:
	if _filter_enabled == false:												# apply filter
		return

	if _zoom_index > _filter_index:												# zoom in 		(better pixel aesthetic)
		_viewport.canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST

	elif _zoom_index <= _filter_index:											# zoom out 		(removes "pixel jitter")
		_viewport.canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_LINEAR
