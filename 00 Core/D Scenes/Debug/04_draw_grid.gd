class_name DrawGrid
extends Node

var _is_enabled: bool = false
var _show_label: bool = false

var _viewport: Viewport

var _grid_color: Color = "f9f9f91a"
var _font_color: Color = "f9f9f980"
var _font_hover: Color = "f9f9f9"

var _font_size: int = 4

var _wide: int = MyGrid.wide
var _tall: int = MyGrid.tall
var _cell_size: int = MyGrid.cell_size

var _text_margin: Vector2 = Vector2(1.0, 3.0)
var _global_TL: Vector2 = MyGrid.margin_TL

var _coord_T: int = 0
var _coord_R: int = _wide - 1

var _mouse_global: Vector2
var _mouse_coord: Vector2
var _mouse_index: int


func _ready() -> void:
	_viewport = get_viewport()

	MyDraw.draw.connect(_on_draw)


func _unhandled_key_input(event: InputEvent) -> void:
	var key_event: = event as InputEventKey
	var key: Key = key_event.keycode

	if key_event.pressed == false:
		return

	if key == KEY_T:
		_is_enabled = !_is_enabled
		MyDraw.queue_redraw()

	if key == KEY_Y:
		_show_label = !_show_label
		MyDraw.queue_redraw()


func _unhandled_input(event: InputEvent) -> void:
	if _is_enabled == false:
		return

	if event is InputEventMouseMotion:
		_mouse_global = _viewport.get_canvas_transform().affine_inverse() * _viewport.get_mouse_position()
		_mouse_coord = MyGrid.global_to_coord(_mouse_global)
		_mouse_index = MyGrid.global_to_index(_mouse_global)
		MyDraw.queue_redraw()


func _on_draw() -> void:
	if _is_enabled == false:
		return

	_draw_grid_lines()

	_draw_hover_rect()
	_draw_hover_index()

	if _show_label == true:
		_draw_grid_label()														# top and right labels

		_draw_mouse_label()														# label mouse highlights
		_draw_mouse_corner() 													# index on top-right


func _draw_grid_lines() -> void:
	MyDraw.rect(MyGrid.grid_rect)

	var cell_pos: Vector2
	for y in _tall:
		for x in _wide:
			cell_pos = Vector2(x, y) * _cell_size + _global_TL
			MyDraw.rect(Rect2(cell_pos, Vector2(_cell_size, _cell_size)), _grid_color)


func _draw_hover_rect() -> void:
	if MyGrid.has_global(_mouse_global) == false:
		return

	var coord: Vector2 = _mouse_coord * _cell_size + _global_TL
	MyDraw.rect(Rect2i(coord, Vector2(_cell_size, _cell_size)), _font_color)


func _draw_hover_index() -> void:
	if MyGrid.has_global(_mouse_global) == false:
		return

	if _show_label == true \
	&& (is_equal_approx(_mouse_coord.x, _coord_R) \
	|| is_equal_approx(_mouse_coord.y, _coord_T)):								# avoid showing on grid label
		return

	var coord: Vector2 = _mouse_coord * _cell_size + _global_TL + _text_margin
	MyDraw.text(coord, "%03d" % _mouse_index, _font_size, _font_color)


func _draw_grid_label() -> void:
	var adjust: Vector2 = _global_TL + _text_margin

	var global_T: int = (_coord_T * _cell_size) + adjust.y
	var global_R: int = (_coord_R * _cell_size) + adjust.x

	var global_x: float
	var global_y: float

	for x in _wide - 1:
		global_x = x * _cell_size + adjust.x
		MyDraw.text_xy(global_x, global_T, "%03d" % x, _font_size, _font_color)

	for y in _tall - 1:
		global_y = (y + 1) * _cell_size + adjust.y
		MyDraw.text_xy(global_R, global_y, "%03d" % (y + 1), _font_size, _font_color)


func _draw_mouse_label() -> void:
	if MyGrid.has_global(_mouse_global) == false:
		return

	var adjust: Vector2 = _global_TL + _text_margin

	var global_T: int = (_coord_T * _cell_size) + adjust.y
	var global_R: int = (_coord_R * _cell_size) + adjust.x

	var global_x: float = _mouse_coord.x * _cell_size + adjust.x
	var global_y: float = _mouse_coord.y * _cell_size + adjust.y

	if is_equal_approx(_mouse_coord.x, _coord_R) == false:
		MyDraw.text_xy(global_x, global_T, "%03d" % _mouse_coord.x, _font_size, _font_hover)

	if is_equal_approx(_mouse_coord.y, _coord_T) == false:
		MyDraw.text_xy(global_R, global_y, "%03d" % _mouse_coord.y, _font_size, _font_hover)


func _draw_mouse_corner() -> void:
	if MyGrid.has_global(_mouse_global) == false:
		return

	var corner: Vector2 = Vector2(_coord_R * _cell_size, _coord_T * _cell_size) + _global_TL + _text_margin
	MyDraw.text(corner, "%03d" % _mouse_index, _font_size, _font_color)
