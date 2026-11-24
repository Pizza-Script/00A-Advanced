class_name DrawFrame
extends Node

# NOTE: y is inverted in godot
# 067 Vector Math

# frame = MyGrid.global_to_frame(global)
# global = MyGrid.frame_to_global(frame)
# global = MyGrid.global_snap_to_frame(global)
# frame = MyGrid.frame_snap_to_frame(frame)

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

var _text_margin: Vector2 = Vector2(1.0, 3.0)															# for text

var _global_M: Vector2 = MyGrid.margin_TL + MyGrid.grid_rect.size * 0.5
var _global_LT: Vector2 = MyGrid.grid_rect.position
var _global_RB: Vector2 = MyGrid.grid_rect.end

var _quad_wide: int = int(_wide * 0.5)
var _quad_tall: int = int(_tall * 0.5)

var _mouse_global: Vector2
var _mouse_coord: Vector2
var _mouse_frame: Vector2i
var _mouse_snap: Vector2


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
		_show_label = !_show_label
		MyDraw.queue_redraw()


func _unhandled_input(event: InputEvent) -> void:
	if _is_enabled == false:
		return

	if event is InputEventMouseMotion:
		_mouse_global = _viewport.get_canvas_transform().affine_inverse() * _viewport.get_mouse_position()
		_mouse_coord = MyGrid.global_to_coord(_mouse_global)
		_mouse_frame = MyGrid.global_to_frame(_mouse_global)
		_mouse_snap = MyGrid.global_snap_to_frame(_mouse_global)
		MyDraw.queue_redraw()


func _on_draw() -> void:
	if _is_enabled == false:
		return

	_draw_grid_lines()
	_draw_mouse_hover()
	_draw_mouse_lines()

	if _show_label == true:
		_draw_grid_label()														# top and right labels
		_draw_mouse_label()														# label mouse highlights


func _draw_grid_lines() -> void:
	MyDraw.rect(MyGrid.grid_rect)

	MyDraw.cross(_global_M, 0.75, 0.5)
	MyDraw.line(Vector2(_global_M.x, _global_LT.y), Vector2(_global_M.x, _global_RB.y))
	MyDraw.line(Vector2(_global_LT.x, _global_M.y), Vector2(_global_RB.x, _global_M.y))

	var cell_pos: Vector2
	for y in _tall:
		for x in _wide:
			cell_pos = Vector2(x, y) * _cell_size + _global_LT
			MyDraw.rect(Rect2(cell_pos, Vector2(_cell_size, _cell_size)), _grid_color)


func _draw_mouse_hover() -> void:
	_mouse_snap = MyGrid.global_snap_to_frame(_mouse_global)
	MyDraw.cross(_mouse_snap, 1.0, 0.75)
	MyDraw.text(_mouse_snap + Vector2(-12.0, -4.0), "(%+1d,%+1d)" % [_mouse_frame.x, _mouse_frame.y], _font_size, _font_color)


func _draw_grid_label() -> void:
	var global_T: float = _global_LT.y + _text_margin.y - 7.0
	var global_R: float = _global_RB.x + _text_margin.x + 2.0

	var global_x: float
	var global_y: float

	MyDraw.text_xy(_global_M.x - 2.0, global_T, "0", _font_size, _font_color)
	for x in _quad_wide:
		global_x = _global_M.x + ((x + 1) * _cell_size) - 3.0
		MyDraw.text_xy(global_x, global_T, "%+1d" % [(x + 1)], _font_size, _font_color)

		global_x = _global_M.x + ((x + 1) * -1 * _cell_size) - 3.0
		MyDraw.text_xy(global_x, global_T, "%+1d" % [(x + 1) * -1], _font_size, _font_color)

	MyDraw.text_xy(global_R + 2.0, _global_M.y + 1.0, "0", _font_size, _font_color)
	for y in _quad_tall:
		global_y = _global_M.y + ((y + 1) * _cell_size) + 1.0
		MyDraw.text_xy(global_R, global_y, "%+1d" % [(y + 1) * -1], _font_size, _font_color)

		global_y = _global_M.y + ((y + 1) * -1 * _cell_size) + 1.0
		MyDraw.text_xy(global_R, global_y, "%+1d" % [(y + 1)], _font_size, _font_color)


func _draw_mouse_label() -> void:
	if MyGrid.has_global(_mouse_global) == false:
		return

	var global_T: float = _global_LT.y + _text_margin.y - 7.0
	var global_R: float = _global_RB.x + _text_margin.x + 2.0

	if _mouse_frame.x == 0:
		MyDraw.text_xy(_global_M.x - 2.0, global_T, "0", _font_size, _font_hover)
	else:
		var global_x: float = _global_M.x + (_mouse_frame.x * _cell_size) - 3.0
		MyDraw.text_xy(global_x, global_T, "%+1d" % _mouse_frame.x, _font_size, _font_hover)

	if _mouse_frame.y == 0:
		MyDraw.text_xy(global_R + 2.0, _global_M.y + 1.0, "0", _font_size, _font_hover)
	else:
		var global_y: float = _global_M.y + (_mouse_frame.y * -1 * _cell_size) + 1.0
		MyDraw.text_xy(global_R, global_y, "%+1d" % [_mouse_frame.y * -1], _font_size, _font_hover)


func _draw_mouse_lines() -> void:
	if MyGrid.has_global(_mouse_global) == false:
		return

	MyDraw.line(_mouse_snap, Vector2(_mouse_snap.x, _global_LT.y), -1.0, _font_color)
	MyDraw.line(_mouse_snap, Vector2(_global_RB.x, _mouse_snap.y), -1.0, _font_color)
