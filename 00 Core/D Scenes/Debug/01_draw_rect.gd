class_name DrawRect
extends Node

var _world_size: Vector2
var _world_min: Vector2
var _world_max: Vector2
var _world_rect: MyRect2

var _viewport: Viewport

var _mouse_position: Vector2
var _clamp_position: Vector2													# nearest if outside rect
var _close_position: Vector2													# nearest if inside rect


func _ready() -> void:
	_world_size = MyCore.world_size
	_world_min = Vector2(32.0, 32.0)
	_world_max = _world_size - _world_min
	_world_rect = MyRect2.new_pos(_world_min, _world_max - _world_min) 			# twice margin, due to .start

	_viewport = get_viewport()

	MyDraw.draw.connect(_on_draw)
	MyDraw.queue_redraw()


func _on_draw() -> void:
	MyDraw.rect(_world_rect.rect)

	MyDraw.circle(_clamp_position, 4.0, Color.GREEN)
	MyDraw.cross(_close_position, 8.0, -1, Color.RED)

	MyDraw.cross(_world_rect.closest_point(_mouse_position), 1.0, 1.0)

	MyDraw.text_auto("CLAMP: (%06.2f, %06.2f) IF OUTSIDE" % [_clamp_position.x, _clamp_position.y], MyDraw.TL, Color.GREEN)
	MyDraw.text_auto("CLOSE: (%06.2f, %06.2f) IF INSIDE" % [_close_position.x, _close_position.y], MyDraw.TL, Color.RED)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		_mouse_position = _viewport.get_canvas_transform().affine_inverse() * _viewport.get_mouse_position()
		_clamp_position = _mouse_position.clamp(_world_min, _world_max)			# outside only (if inside = mouse pos)
		_close_position = _rect_closest_point(_world_rect, _mouse_position)		# inside only (if outside = corner issue)
		MyDraw.queue_redraw()


func _rect_closest_point(rect: MyRect2, point: Vector2) -> Vector2:
	var start: Vector2 = point - rect.position
	var stop: Vector2 = rect.end - point

	var minimum: Vector2 = start.min(stop)
	var smallest: float = minf(minimum.x, minimum.y)
	var closest: Vector2

	if smallest == start.x:
		closest = Vector2(rect.L, point.y)
	elif smallest == stop.x:
		closest = Vector2(rect.R, point.y)
	elif smallest == start.y:
		closest = Vector2(point.x, rect.T)
	elif smallest == stop.y:
		closest = Vector2(point.x, rect.B)

	return closest
