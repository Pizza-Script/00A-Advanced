class_name DrawCircle
extends Node

var _is_hovered: bool
var _is_circle_held: bool
var _is_radius_held: bool

var _world_size: Vector2
var _world_min: Vector2
var _world_max: Vector2
var _world_rect: MyRect2

var _circle_radius: float
var _circle_position: Vector2
var _circle_nearest: Vector2
var _circle_distance: float

var _mouse_position: Vector2
var _hold_position: Vector2


func _vars() -> void:
	_is_circle_held = false
	_is_radius_held = false

	_world_size = MyCore.world_size
	_world_min = Vector2(8.0, 8.0)
	_world_max = _world_size - _world_min
	_world_rect = MyRect2.new_pos(Vector2.ZERO, _world_size)					# for radius clamp

	_circle_radius = 32.0
	_circle_position = _world_size * 0.5


func _ready() -> void:
	_vars()

	MyDraw.draw.connect(_on_draw)
	MyDraw.queue_redraw()


func _on_draw() -> void:
	MyDraw.cross(_circle_position, 1.0)
	MyDraw.circle(_circle_position, _circle_radius)

	MyDraw.cross(_mouse_position, 3.0)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse_event: InputEventMouseButton = event as InputEventMouseButton

		if mouse_event.button_index == MOUSE_BUTTON_LEFT:						# NOTE: MOVE
			_mouse_position = mouse_event.position

			if mouse_event.pressed == true:
				_circle_distance = _mouse_position.distance_to(_circle_position)

				if _circle_distance < _circle_radius + 1.0 \
				&& _circle_distance > _circle_radius - 1.0:						# mouse in circle border
					_is_radius_held = true										# resize

				elif _circle_distance <= _circle_radius:						# mouse in circle body
					_hold_position = _circle_position - _mouse_position			# move
					_is_circle_held = true

			elif mouse_event.pressed == false:									# mouse released
				_is_radius_held = false
				_is_circle_held = false

	if event is InputEventMouseMotion:
		var mouse_event: = event as InputEventMouseMotion
		_mouse_position = mouse_event.position
		_circle_distance = _mouse_position.distance_to(_circle_position)
		MyDraw.queue_redraw()

		if _circle_distance < _circle_radius + 1.0 \
		&& _circle_distance > _circle_radius - 1.0:								# mouse in circle border
			Input.set_default_cursor_shape(Input.CursorShape.CURSOR_HSIZE)
			_is_hovered = true

		elif _circle_distance < _circle_radius:									# mouse in circle body
			Input.set_default_cursor_shape(Input.CursorShape.CURSOR_MOVE)
			_is_hovered = true

		else:																	# mouse outside circle
			if _is_hovered == true:
				Input.set_default_cursor_shape(Input.CursorShape.CURSOR_ARROW)
				_is_hovered = false

		if _is_circle_held == true:												# move
			_circle_position = (_mouse_position + _hold_position).clamp(_world_min, _world_max)

		elif _is_radius_held == true:											# resize
			_circle_radius = _mouse_position.distance_to(_circle_position)

			_circle_nearest = _world_rect.closest_point(_circle_position)
			_circle_distance = _circle_position.distance_to(_circle_nearest)
			_circle_radius = clampf(_circle_radius, 1.0, _circle_distance)		# clamp to world

			_world_min = Vector2(_circle_radius, _circle_radius)
			_world_max = _world_size - _world_min
