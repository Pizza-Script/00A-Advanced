class_name MyCameraFollow
extends MyCamera

@export var _target_node: Node2D

var _position: Vector2
var _position_min: Vector2
var _position_max: Vector2


func _ready() -> void:
	if _target_node == null:
		printerr("MISSING CAMERA TARGET")

	await _target_node.ready
	_position = _target_node.position
	position = _position

	limit_left = 0
	limit_top = 0
	limit_right = int(_world_size.x)											# camera 'view' would stop at the limit
	limit_bottom = int(_world_size.y)											# camera position will still move past limit

	await get_tree().current_scene.ready
	_zoom_index = _zoom_start
	_zoom_apply()

	if _zoom_start > _zoom_in_limit:											# prevent confusion when limit is 0
		_zoom_in_limit = _zoom_start

	if _zoom_start < _zoom_out_limit:
		_zoom_out_limit = _zoom_start


func _process(_delta: float) -> void:
	if _target_node.position.is_equal_approx(_position):						# did not move
		return

	_position = _target_node.position
	if _zoom_index > 0:															# don't move when fully zoomed out
		position = _position.clamp(_position_min, _position_max)

	if drag_horizontal_enabled == true || drag_vertical_enabled == true:		# handle drag
		_position = get_screen_center_position().clamp(_position_min, _position_max)

	on_move.emit(_position)
