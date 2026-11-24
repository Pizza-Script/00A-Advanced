class_name MyCameraInput
extends MyCamera

@export var _zoom_to_mouse: bool = false
@export var _speed: int = 200

var _viewport_size: Vector2
var _viewport_half: Vector2

var _position_min: Vector2
var _position_max: Vector2
var _position: Vector2


func _ready() -> void:
	super()

	_position = position

	limit_left = 0
	limit_top = 0
	limit_right = int(_world_size.x)											# camera 'view' would stop at the limit
	limit_bottom = int(_world_size.y)											# camera position will still move past limit


func _process(delta: float) -> void:
	var direction: = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")# 0.707107
	if direction != Vector2.ZERO:
		_position += direction * _speed * delta
		_position = _position.clamp(_position_min, _position_max)
		position = _position
		on_move.emit(_position)


func _zoom_in() -> void:
	if _zoom_tween != null && _zoom_tween.is_valid() == true:					# wait for zoom_smooth to end
		return

	if _zoom_index == _zoom_in_limit:
		return

	_zoom_index += 1
	_zoom_apply(1)																# must override parent _zoom_apply()


func _zoom_apply(zoom_sign: int = -1) -> void:
	var zoom_float: float = 2.0 ** _zoom_index
	var zoom_v2: Vector2 = Vector2(zoom_float, zoom_float)

	_viewport_size = MyCore.viewport_size
	_viewport_half = MyCore.viewport_size * 0.5

	_position_min = _viewport_half / zoom_v2
	_position_max = _world_size - _position_min

	if _zoom_smooth == false:
		_zoom_tween = create_tween()
		_zoom_tween.tween_callback(func(): zoom = zoom_v2)
		_zoom_tween.tween_interval(0.07)										# prevent very quick zooms

		if _zoom_to_mouse == true && zoom_sign == 1:							# zoom in
			_position = get_global_mouse_position().clamp(_position_min, _position_max)
			_warp_mouse(_world_half)
		else:
			_position = get_screen_center_position().clamp(_position_min, _position_max)

		position = _position
		on_zoom.emit(zoom_v2)

	elif _zoom_smooth == true:
		_zoom_tween = create_tween()

		if _zoom_to_mouse == true && zoom_sign == 1:							# zoom in
			_position = get_global_mouse_position().clamp(_position_min, _position_max)
			_zoom_tween.tween_callback(func(): position = _position)
			# _zoom_tween.tween_property(self, "position", _position, _zoom_smooth_time)

			# TODO: wrap on edge

			var _mouse_start: Vector2 = _viewport.get_mouse_position()			# move mouse to screen center
			_zoom_tween.parallel().tween_method(_warp_mouse, _mouse_start, _world_half, _zoom_smooth_time)
		else:
			_position = get_screen_center_position().clamp(_position_min, _position_max)
			_zoom_tween.tween_property(self, "position", _position, _zoom_smooth_time)

		_zoom_tween.parallel().tween_property(self, "zoom", zoom_v2, _zoom_smooth_time)
		_zoom_tween.tween_callback(func(): on_zoom.emit(zoom_v2))

	_zoom_filter()


func _move(my_position: Vector2) -> void:
	position = my_position
	on_move.emit(my_position)


func _warp_mouse(target: Vector2) -> void:										# based on _viewport_size
	_viewport.warp_mouse(target)
