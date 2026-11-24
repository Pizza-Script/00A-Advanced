@tool
# class_name MyDraw																# all about _draw()
extends Node

class_name _MyDraw																# class_name for @tool use
static var tool: _MyDraw														# singleton name for globals

# MyDraw.text(_position, _string)
# MyDraw.text_xy(_pos_x, _pos_y, _string)
# MyDraw.text_multi(_position, _string)

# MyDraw.text_camera(_position, _string)
# MyDraw.text_auto(_string, edge = TL)
# MyDraw.text_auto_space(_count = 1, edge = TL)

# MyDraw.line(_start, _end)
# MyDraw.line_deg(_start, _degree, _length)
# MyDraw.line_rad(_start, _radian, _length)

# MyDraw.cross(_position, _length)
# MyDraw.arrow(_position, _degree, _length)
# MyDraw.arrow_rad(_position, _radian, _length)

# MyDraw.circle(_position, _radius)
# MyDraw.circle_full(_position, _radius)

# MyDraw.rect(_rect)
# MyDraw.rect_full(_rect)

# MyDraw.texture(_image, _position)
# MyDraw.polygon(_points, _colors)
# MyDraw.polyline(_points, color)

# _camera FUNCTIONS


signal draw

const TL: int = 0
const BL: int = 1
const TR: int = 2
const BR: int = 3

var _draw_font: Font = preload("res://00 Core/E Assets/Fonts/5x5 mono.ttf")

var _world_size: Vector2 = MyCore.world_size
var _world_half: Vector2 = MyCore.world_size * 0.5

var _viewport_size: Vector2 = MyCore.viewport_size
var _viewport_half: Vector2 = MyCore.viewport_size * 0.5

var _canvas: CanvasLayer														# drawn above all other layers
var _node: Node2D																# to make all global into Node
var _camera: MyCamera
var _camera_zoom: Vector2 = Vector2.INF
var _camera_size: Vector2
var _camera_half: Vector2
var _camera_position: Vector2													# to handle drag

var _text_auto_count: Array[int] = [0, 0, 0, 0]
var _text_auto_start: Vector2 = Vector2(4.0, 8.0)
var _text_auto_shift: Vector2 = Vector2(0.0, 8.0)
var _text_auto_size: int = 8

var _text_auto_count_camera: Array[int] = [0, 0, 0, 0]
var _text_auto_start_camera: Vector2 = Vector2(4.0, 8.0)
var _text_auto_shift_camera: Vector2 = Vector2(0.0, 8.0)
var _text_auto_size_camera: int = 8


func _ready() -> void:
	if Engine.is_editor_hint() == true:
		return

	MyCore.on_viewport_edit.connect(_on_viewport_edit)
	MyCore.on_world_edit.connect(_on_world_edit)

	tool = self																	# add here to avoid race conditions

	await get_tree().current_scene.ready
	_canvas = CanvasLayer.new()
	_canvas.name = "MyCanvasLayer"
	_canvas.layer = RenderingServer.CANVAS_LAYER_MAX
	_canvas.follow_viewport_enabled = true
	add_child(_canvas)

	_node = Node2D.new()
	_node.name = "MyDrawNode"
	_node.draw.connect(_on_draw)
	_node.queue_redraw()

	_canvas.add_child(_node)
	MyNode.set_z_index((_node as Node2D), MyNode.ZIndex.DRAW)

	_camera = get_viewport().get_camera_2d()
	if _camera == null:															# for scenes w/o Camera2D (i.e. F6)
		return

	_camera.on_zoom.connect(_on_camera_zoom)
	_camera.on_move.connect(_on_camera_move)

	_camera_zoom = _camera.zoom
	_camera_size = _viewport_size / _camera_zoom
	_camera_half = _viewport_half / _camera_zoom
	_camera_position = _camera.position


func _on_draw() -> void:
	draw.emit()

	_text_auto_count.fill(0)
	_text_auto_count_camera.fill(0)


func queue_redraw() -> void:
	if Engine.is_editor_hint() == true:
		return

	if _node != null:
		_node.queue_redraw()


func text(pos: Vector2, _text: String, font_size: int = 16, color: Color = "f9f9f9") -> void:
	_node.draw_string(_draw_font, pos, _text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, color)


func text_xy(pos_x: float, pos_y: float, _text: String, font_size: int = 16, color: Color = "f9f9f9") -> void:
	_node.draw_string(_draw_font, Vector2(pos_x, pos_y), _text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, color)


func text_multi(pos: Vector2, _text: String, font_size: int = 16, color: Color = "f9f9f9") -> void:
	_node.draw_multiline_string(_draw_font, pos, _text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, -1, color)


func text_auto(_text: String, edge: int = 0, color: Color = "f9f9f9") -> void:
	var start_pos: Vector2
	var shift_pos: Vector2
	var final_pos: Vector2
	var alignment: HorizontalAlignment

	match edge:
		TL:
			start_pos = _text_auto_start
			shift_pos = _text_auto_shift
			alignment = HORIZONTAL_ALIGNMENT_LEFT
		BL:
			start_pos.x = _text_auto_start.x
			start_pos.y = _world_size.y - _text_auto_start.y
			shift_pos = _text_auto_shift * -1
			alignment = HORIZONTAL_ALIGNMENT_LEFT
		TR:
			start_pos.x = _world_size.x - _text_auto_start.x - 50.0				# TODO:
			start_pos.y = _text_auto_start.y
			shift_pos = _text_auto_shift
			alignment = HORIZONTAL_ALIGNMENT_RIGHT
		BR:
			start_pos.x = _world_size.x - _text_auto_start.x - 50.0
			start_pos.y = _world_size.y - _text_auto_start.y
			shift_pos = _text_auto_shift * -1
			alignment = HORIZONTAL_ALIGNMENT_RIGHT

	final_pos = start_pos + (shift_pos * _text_auto_count[edge])
	_text_auto_count[edge] += 1

	# final_pos = _camera.to_global(final_pos) - _camera_half					# camera adjustments
	# final_pos = (_camera_position + final_pos) - _camera_half					# handles camera drag
	_node.draw_string(_draw_font, final_pos, _text, alignment, -1, _text_auto_size, color)


func text_auto_space(count: int = 1, edge: int = 0) -> void:
	for i in count:
		text_auto("", edge)


func line(pos_on: Vector2, pos_to: Vector2, weight: float = -1.0, color: Color = "f9f9f9") -> void:
	_node.draw_line(pos_on, pos_to, color, weight)


func line_deg(pos_on: Vector2, degree: float, length: float, weight: float = -1.0, color: Color = "f9f9f9") -> void:
	var direction: Vector2 = Vector2.RIGHT.rotated(deg_to_rad(degree))
	var pos_to: Vector2 = pos_on + (direction * length)
	_node.draw_line(pos_on, pos_to, color, weight)


func line_rad(pos_on: Vector2, radian: float, length: float, weight: float = -1.0, color: Color = "f9f9f9") -> void:
	var direction: Vector2 = Vector2.RIGHT.rotated(radian)
	var pos_to: Vector2 = pos_on + (direction * length)
	_node.draw_line(pos_on, pos_to, color, weight)


func cross(pos: Vector2, length: float = 1.0, weight: float = -1.0, color: Color = "f9f9f9") -> void:
	var half_length: float = length * 0.5
	var L_on: Vector2 = pos + Vector2(half_length, 0).rotated(deg_to_rad(225))
	var L_to: Vector2 = pos + Vector2(half_length, 0).rotated(deg_to_rad(45))
	var R_on: Vector2 = pos + Vector2(half_length, 0).rotated(deg_to_rad(315))
	var R_to: Vector2 = pos + Vector2(half_length, 0).rotated(deg_to_rad(135))
	_node.draw_line(L_on, L_to, color, weight)
	_node.draw_line(R_on, R_to, color, weight)


func arrow(pos: Vector2, degree: float, length: float, weight: float = -1.0, color: Color = "f9f9f9") -> void:
	var half_length: float = length * 0.5
	var L_on: Vector2 = pos + Vector2(half_length, 0).rotated(deg_to_rad(degree + 0))
	var L_to: Vector2 = pos + Vector2(half_length, 0).rotated(deg_to_rad(degree + 225))
	var R_on: Vector2 = pos + Vector2(half_length, 0).rotated(deg_to_rad(degree + 0))
	var R_to: Vector2 = pos + Vector2(half_length, 0).rotated(deg_to_rad(degree + 135))
	_node.draw_line(L_on, L_to, color, weight)
	_node.draw_line(R_on, R_to, color, weight)


func arrow_rad(pos: Vector2, radian: float, length: float, weight: float = -1.0, color: Color = "f9f9f9") -> void:
	var half_length: float = length * 0.5
	var L_on: Vector2 = pos + Vector2(half_length, 0).rotated(radian + deg_to_rad(0))
	var L_to: Vector2 = pos + Vector2(half_length, 0).rotated(radian + deg_to_rad(225))
	var R_on: Vector2 = pos + Vector2(half_length, 0).rotated(radian + deg_to_rad(0))
	var R_to: Vector2 = pos + Vector2(half_length, 0).rotated(radian + deg_to_rad(135))
	_node.draw_line(L_on, L_to, color, weight)
	_node.draw_line(R_on, R_to, color, weight)


func circle(center: Vector2, radius: float, color: Color = "f9f9f9", width: float = -1.0) -> void:
	# _node.draw_arc(center, radius, 0, TAU, 1000, color, width)					# square-ish circle
	_node.draw_circle(center, radius, color, false, width)


func circle_full(center: Vector2, radius: float, color: Color = "f9f9f9") -> void:
	_node.draw_circle(center, radius, color)


func rect(_rect: Rect2, color: Color = "f9f9f9", width: int = -1) -> void:
	_node.draw_rect(_rect, color, false, width)


func rect_full(_rect: Rect2, color: Color = "f9f9f9") -> void:
	_node.draw_rect(_rect, color)


func texture(_texture: Texture2D, pos: Vector2) -> void:
	_node.draw_texture(_texture, pos)


func polygon(_points: PackedVector2Array, color: PackedColorArray) -> void:		# can be 1 color
	_node.draw_polygon(_points, color)


func polyline(_points: PackedVector2Array, color: Color, width: float = -1.0, antialiased: bool = false) -> void:
	_node.draw_polyline(_points, color, width, antialiased)


### CAMERA ###
func _view_to_world(pos: Vector2) -> Vector2:									# for draw to follow camera
	return (pos / _camera_zoom) + (_camera_position - _camera_half)


func _world_to_view(pos: Vector2) -> Vector2:
	return (pos - (_camera_position - _camera_half)) * _camera_zoom


func text_camera(pos: Vector2, _text: String, font_size: int = 16, color: Color = "f9f9f9") -> void:
	text(_view_to_world(pos), _text, font_size, color)


func text_xy_camera(pos_x: float, pos_y: float, _text: String, font_size: int = 16, color: Color = "f9f9f9") -> void:
	var pos: Vector2 = _view_to_world(Vector2(pos_x, pos_y))
	text_xy(pos.x, pos.y, _text, font_size, color)


func text_multi_camera(pos: Vector2, _text: String, font_size: int = 16, color: Color = "f9f9f9") -> void:
	text_multi(_view_to_world(pos), _text, font_size, color)


func text_auto_camera(_text: String, edge: int = 0, color: Color = "f9f9f9") -> void:
	var start_pos: Vector2
	var shift_pos: Vector2
	var final_pos: Vector2
	var alignment: HorizontalAlignment

	match edge:
		TL:
			start_pos = _text_auto_start_camera
			shift_pos = _text_auto_shift_camera
			alignment = HORIZONTAL_ALIGNMENT_LEFT
		BL:
			start_pos.x = _text_auto_start_camera.x
			start_pos.y = _camera_size.y - _text_auto_start_camera.y
			shift_pos = _text_auto_shift_camera * -1
			alignment = HORIZONTAL_ALIGNMENT_LEFT
		TR:
			start_pos.x = _camera_size.x - _text_auto_start_camera.x - 50.0				# TODO:
			start_pos.y = _text_auto_start_camera.y
			shift_pos = _text_auto_shift_camera
			alignment = HORIZONTAL_ALIGNMENT_RIGHT
		BR:
			start_pos.x = _camera_size.x - _text_auto_start_camera.x - 50.0
			start_pos.y = _camera_size.y - _text_auto_start_camera.y
			shift_pos = _text_auto_shift_camera * -1
			alignment = HORIZONTAL_ALIGNMENT_RIGHT

	final_pos = start_pos + (shift_pos * _text_auto_count_camera[edge])
	_text_auto_count_camera[edge] += 1

	# final_pos = _camera.to_global(final_pos) - _camera_half					# camera adjustments
	final_pos = (_camera_position + final_pos) - _camera_half					# handles camera drag
	_node.draw_string(_draw_font, final_pos, _text, alignment, -1, _text_auto_size_camera, color)


func text_auto_space_camera(count: int = 1, edge: int = 0) -> void:
	for i in count:
		text_auto_camera("", edge)


func line_camera(pos_on: Vector2, pos_to: Vector2, weight: float = -1.0, color: Color = "f9f9f9") -> void:
	line(_view_to_world(pos_on), _view_to_world(pos_to), weight, color)


func line_deg_camera(pos_on: Vector2, degree: float, length: float, weight: float = -1.0, color: Color = "f9f9f9") -> void:
	line_deg(_view_to_world(pos_on), degree, length, weight, color)


func line_rad_camera(pos_on: Vector2, radian: float, length: float, weight: float = -1.0, color: Color = "f9f9f9") -> void:
	line_rad(_view_to_world(pos_on), radian, length, weight, color)


func cross_camera(pos: Vector2, length: float = 1.0, weight = -1.0, color: Color = "f9f9f9") -> void:
	cross(_view_to_world(pos), length, weight, color)


func arrow_camera(pos: Vector2, degree: float, length: float, weight: float = -1.0, color: Color = "f9f9f9") -> void:
	arrow(_view_to_world(pos), degree, length, weight, color)


func arrow_rad_camera(pos: Vector2, radian: float, length: float, weight: float = -1.0, color: Color = "f9f9f9") -> void:
	arrow_rad(_view_to_world(pos), radian, length, weight, color)


func circle_camera(center: Vector2, radius: float, color: Color = "f9f9f9", width: float = -1.0) -> void:
	circle(_view_to_world(center), radius, color, width)


func circle_full_camera(center: Vector2, radius: float, color: Color = "f9f9f9") -> void:
	circle_full(_view_to_world(center), radius, color)


func rect_camera(_rect: Rect2, color: Color = "f9f9f9", width: int = -1) -> void:
	var _rect_camera: Rect2 = _rect
	_rect_camera.position = _view_to_world(_rect.position)
	rect(_rect_camera, color, width)


func rect_full_camera(_rect: Rect2, color: Color = "f9f9f9") -> void:
	var _rect_camera: Rect2 = _rect
	_rect_camera.position = _view_to_world(_rect.position)
	rect_full(_rect_camera, color)


func texture_camera(_texture: Texture2D, pos: Vector2) -> void:
	texture(_texture, _view_to_world(pos))


func polygon_camera(_points: PackedVector2Array, color: PackedColorArray) -> void:
	var points_camera: PackedVector2Array
	for point in _points:
		points_camera.append(_view_to_world(point))
	polygon(points_camera, color)


func polyline_camera(_points: PackedVector2Array, color: Color, width: float = -1.0, antialiased: bool = false) -> void:
	var points_camera: PackedVector2Array
	for point in _points:
		points_camera.append(_view_to_world(point))
	polyline(_points, color, width, antialiased)


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
	queue_redraw()


func _on_camera_move(_position: Vector2) -> void:
	_camera_position = _position
	queue_redraw()
