@tool
# class_name MyGrid																# all about tiles
extends Node

class_name _MyGrid																# class_name for @tool use
static var tool: _MyGrid														# singleton name for globals

# MyGrid.has_global(v2)

# MyGrid.coord_to_global(v2)
# MyGrid.coord_to_index(v2)

# MyGrid.index_to_global(i)
# MyGrid.index_to_coord(i)

# MyGrid.global_to_coord(v2)
# MyGrid.global_to_index(v2)
# MyGrid.global_to_snap(v2)

# MyGrid.cell_near[]		= compute_near()
# MyGrid.cell_near_four[]	= compute_near_four()
# MyGrid.cell_rect[]		= compute_rect()

# MyGrid.cell_global[]		= compute_global()
# MyGrid.cell_coord[]		= compute_coord()

# MyGrid.global_to_frame(v2)
# MyGrid.frame_to_global(v2)
# MyGrid.global_snap_to_frame(v2)
# MyGrid.frame_snap_to_frame()

# MyGrid.is_border(index, border_size = 1)
# MyGrid.compute_border(border_size = 1)
# MyGrid.compute_border_four(R = 1, B = 1, L = 1, T = 1)

# _size FUNCTIONS

signal on_world_edit															# NOTE: all Arrays recalculated

enum
{
	TL, T, TR,																	# 0, 1, 2
	 L, C,	R,																	# 3, 4, 5
	BL, B, BR,																	# 6, 7, 8
}

var _is_grid_shown: bool = false
var _is_tile_shown: bool = false

var _viewport: Viewport
var _mouse_position: Vector2
var _tile_position: Vector2
var _tile_coord: Vector2
var _tile_index: int
var _tile_rect: Rect2

var margin_TL: Vector2 = Vector2(0.0, 0.0)										# start of grid (origin)
var margin_BR: Vector2 = Vector2(0.0, 0.0)										# relative to _world_size
var margin_sum: Vector2 = margin_TL + margin_BR									# used by my_tile_map_layer

var cell_size: int = 8															# base cell_size
var grid_rect: Rect2 = Rect2(margin_TL, MyCore.world_size - margin_sum)
var wide: int = ceili((MyCore.world_size.x - margin_sum.x) / cell_size)
var tall: int = ceili((MyCore.world_size.y - margin_sum.y) / cell_size)
var size: int = wide * tall

var cell_near: Array[PackedInt32Array] = compute_near()							# 0, 1, 2,		3, 4, 5,	6, 7, 8
var cell_near_four: Array[PackedInt32Array] = compute_near_four()				# R, D, L, T
var cell_rect: Array[Rect2] = compute_rect()

var cell_global: PackedVector2Array = compute_global()							# used in index_to_global()
var cell_coord: PackedVector2Array = compute_coord()							# used in index_to_coord()


func _ready() -> void:
	if Engine.is_editor_hint() == true:
		return

	MyCore.on_world_edit.connect(_on_world_edit)

	MyDraw.draw.connect(_on_draw)
	MyDraw.queue_redraw()

	tool = self																	# add here to avoid race conditions
	_viewport = get_viewport()


func _on_draw() -> void:
	if _is_grid_shown == true:
		for rect in cell_rect:
			MyDraw.rect(rect, "f9f9f91A")

		var global_M: Vector2 = MyGrid.global_to_snap(MyGrid.margin_TL + MyGrid.grid_rect.size * 0.5)
		var global_LT: Vector2 = MyGrid.grid_rect.position
		var global_RB: Vector2 = MyGrid.grid_rect.end

		MyDraw.line(Vector2(global_M.x, global_LT.y), Vector2(global_M.x, global_RB.y), -1.0, "f9f9f966")
		MyDraw.line(Vector2(global_LT.x, global_M.y), Vector2(global_RB.x, global_M.y), -1.0, "f9f9f966")

	if _is_tile_shown == true:
		MyDraw.rect(_tile_rect, "f9f9f980")
		MyDraw.text_camera(_tile_rect.position + Vector2(16.0, -04.0), "INDEX  :%03d" % [_tile_index], 8)
		MyDraw.text_camera(_tile_rect.position + Vector2(16.0, +04.0), "COORD  (%03d, %03d)" % [_tile_coord.x, _tile_coord.y], 8)
		MyDraw.text_camera(_tile_rect.position + Vector2(16.0, +12.0), "GLOBAL (%03d, %03d)" % [_tile_position.x, _tile_position.y], 8)


func _unhandled_key_input(event: InputEvent) -> void:
	var key_event: = event as InputEventKey
	var key: Key = key_event.keycode

	if key_event.pressed == false:
		return

	if key_event.echo == true:
		return

	if key == KEY_G:
		_is_grid_shown = !_is_grid_shown
		MyDraw.queue_redraw()

	if key == KEY_F1:
		_is_tile_shown = !_is_tile_shown
		_compute_tile_info()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if _is_tile_shown == true:
			_compute_tile_info()


func _compute_tile_info() -> void:
	_mouse_position = _viewport.get_canvas_transform().affine_inverse() * _viewport.get_mouse_position()
	_tile_coord = global_to_coord(_mouse_position)
	_tile_index = coord_to_index(_tile_coord)
	_tile_position = cell_global[_tile_index]
	_tile_rect = cell_rect[_tile_index]
	MyDraw.queue_redraw()


func has_global(pos: Vector2) -> bool:
	return grid_rect.has_point(pos)
	# var map_coord: Vector2i = Vector2i((((pos - origin) / cell_size) + Vector2(0.00005, 0.00005)).floor())
	# return map_coord.x >= 0 && map_coord.x < wide && map_coord.y >= 0 && map_coord.y < tall


func coord_to_global(coord: Vector2i) -> Vector2:
	return (Vector2(coord) + Vector2(0.5, 0.5)) * cell_size + margin_TL		# center of square


func coord_to_global_size(coord: Vector2i, _cell_size: int) -> Vector2:
	return (Vector2(coord) + Vector2(0.5, 0.5)) * _cell_size + margin_TL		# center of square


func coord_to_index(coord: Vector2i) -> int:
	return coord.x + coord.y * wide												# x + y * wide


func coord_to_index_size(coord: Vector2i, _cell_size: int) -> int:
	var grid_wide: int = ceili((MyCore.world_size.x - margin_sum.x) / _cell_size)
	return coord.x + coord.y * grid_wide										# x + y * wide


func index_to_global(index: int) -> Vector2:
	return cell_global[index]
	# return (Vector2(index % wide, index / wide) + Vector2(0.5, 0.5)) * cell_size + origin


func index_to_global_size(index: int, _cell_size: int) -> Vector2:
	var grid_wide: int = ceili((MyCore.world_size.x - margin_sum.x) / _cell_size)
	return (Vector2(index % grid_wide, index / grid_wide) + Vector2(0.5, 0.5)) * _cell_size + margin_TL


func index_to_coord(index: int) -> Vector2:
	return cell_coord[index]
	# return Vector2(index % wide, index / wide)


func index_to_coord_size(index: int, _cell_size: int) -> Vector2:
	var grid_wide: int = ceili((MyCore.world_size.x - margin_sum.x) / _cell_size)
	return Vector2(index % grid_wide, index / grid_wide)


func global_to_coord(pos: Vector2) -> Vector2:
	# coord in Vector2 to avoid Vector2i conversions
	# scene > resources > 2d > tile_set.cpp > TileSet::local_to_map
	# + Vector2(0.00005, 0.00005) to avoid float precision errors				# github.com/godotengine/godot/issues/23250

	var map_coord: Vector2 # = Vector2i(((pos - margin_TL) / cell_size).floor())
	pos -= margin_TL															# global origin
	map_coord = pos / cell_size													# global to coords
	map_coord = map_coord.floor()												# prevents [-0.1 to -0.9] == 0.0
	return map_coord


func global_to_coord_size(pos: Vector2, _cell_size: int) -> Vector2:
	var map_coord: Vector2 # = Vector2i(((pos - margin_TL) / _cell_size).floor())
	pos -= margin_TL															# global origin
	map_coord = pos / _cell_size												# global to coords
	map_coord = map_coord.floor()												# prevents [-0.1 to -0.9] == 0.0
	return map_coord


func global_to_index(pos: Vector2) -> int:
	var map_coord: Vector2i = Vector2i(((pos - margin_TL) / cell_size).floor())
	return map_coord.x + map_coord.y * wide


func global_to_index_size(pos: Vector2, _cell_size: int) -> int:
	var grid_wide: int = ceili((MyCore.world_size.x - margin_sum.x) / _cell_size)
	var map_coord: Vector2i = Vector2i(((pos - margin_TL) / _cell_size).floor())
	return map_coord.x + map_coord.y * grid_wide


func global_to_snap(pos: Vector2) -> Vector2:
	var map_coord: Vector2i = Vector2i(((pos - margin_TL) / cell_size).floor())
	return map_coord * cell_size


func global_to_snap_size(pos: Vector2, _cell_size: int) -> Vector2:
	var map_coord: Vector2i = Vector2i(((pos - margin_TL) / _cell_size).floor())
	return map_coord * _cell_size


func compute_near() -> Array[PackedInt32Array]:
	var grid_wide: int = wide
	var grid_tall: int = tall
	var grid_size: int = size

	var grid_near: Array[PackedInt32Array]

	var coord: Vector2i
	var border: PackedInt32Array
	var max_x: int = grid_wide - 1
	var max_y: int = grid_tall - 1

	grid_near.resize(grid_size)
	for index in grid_size:														# 0	1	2
		coord = Vector2i(index % grid_wide, index / grid_wide)					# 3	4	5
		border = [-1, -1, -1, -1, -1, -1, -1, -1, -1]							# 6	7	8

		if index > max_x:
			border[1] = index - grid_wide
			if coord.x > 0:
				border[0] = border[1] - 1
			if coord.x < max_x:
				border[2] = border[1] + 1

		border[4] = index
		if coord.x > 0:
			border[3] = index - 1
		if coord.x < max_x:
			border[5] = index + 1

		if coord.y < max_y:
			border[7] = index + grid_wide
			if coord.x > 0:
				border[6] = border[7] - 1
			if coord.x < max_x:
				border[8] = border[7] + 1

		grid_near[index] = border.duplicate()

	return grid_near


func compute_near_size(_cell_size: int = -1) -> Array[PackedInt32Array]:
	var grid_wide: int = ceili((MyCore.world_size.x - margin_sum.x) / _cell_size)
	var grid_tall: int = ceili((MyCore.world_size.y - margin_sum.y) / _cell_size)
	var grid_size: int = grid_wide * grid_tall

	var grid_near: Array[PackedInt32Array]

	var coord: Vector2i
	var border: PackedInt32Array
	var max_x: int = grid_wide - 1
	var max_y: int = grid_tall - 1

	grid_near.resize(grid_size)
	for index in grid_size:														# 0	1	2
		coord = Vector2i(index % grid_wide, index / grid_wide)					# 3	4	5
		border = [-1, -1, -1, -1, -1, -1, -1, -1, -1]							# 6	7	8

		if index > max_x:
			border[1] = index - grid_wide
			if coord.x > 0:
				border[0] = border[1] - 1
			if coord.x < max_x:
				border[2] = border[1] + 1

		border[4] = index
		if coord.x > 0:
			border[3] = index - 1
		if coord.x < max_x:
			border[5] = index + 1

		if coord.y < max_y:
			border[7] = index + grid_wide
			if coord.x > 0:
				border[6] = border[7] - 1
			if coord.x < max_x:
				border[8] = border[7] + 1

		grid_near[index] = border.duplicate()

	return grid_near


func compute_near_four() -> Array[PackedInt32Array]:
	var grid_wide: int = wide
	var grid_tall: int = tall
	var grid_size: int = size

	var grid_near: Array[PackedInt32Array]

	var max_x: int = grid_wide - 1
	var max_y: int = grid_tall - 1
	var cell_coord: Vector2i

	grid_near.resize(grid_size)
	for index in grid_size:
		cell_coord = Vector2i(index % grid_wide, index / grid_wide)
		grid_near[index] = [-1, -1, -1, -1] as PackedInt32Array					# -1 if out of bounds

		if cell_coord.x != max_x:												# RIGHT
			grid_near[index][0] = index + 1

		if cell_coord.y != max_y:												# DOWN
			grid_near[index][1] = index + grid_wide

		if cell_coord.x != 0:													# LEFT
			grid_near[index][2] = index - 1

		if index > max_x:														# TOP
			grid_near[index][3] = index - grid_wide

	return grid_near


func compute_near_four_size(_cell_size: int = -1) -> Array[PackedInt32Array]:
	var grid_wide: int = ceili((MyCore.world_size.x - margin_sum.x) / _cell_size)
	var grid_tall: int = ceili((MyCore.world_size.y - margin_sum.y) / _cell_size)
	var grid_size: int = grid_wide * grid_tall

	var grid_near: Array[PackedInt32Array]

	var max_x: int = grid_wide - 1
	var max_y: int = grid_tall - 1
	var cell_coord: Vector2i

	grid_near.resize(grid_size)
	for index in grid_size:
		cell_coord = Vector2i(index % grid_wide, index / grid_wide)
		grid_near[index] = [-1, -1, -1, -1] as PackedInt32Array					# -1 if out of bounds

		if cell_coord.x != max_x:												# RIGHT
			grid_near[index][0] = index + 1

		if cell_coord.y != max_y:												# DOWN
			grid_near[index][1] = index + grid_wide

		if cell_coord.x != 0:													# LEFT
			grid_near[index][2] = index - 1

		if index > max_x:														# TOP
			grid_near[index][3] = index - grid_wide

	return grid_near


func compute_rect() -> Array[Rect2]:
	var grid_wide: int = wide
	var grid_tall: int = tall
	var grid_size: int = size

	var _cell_size: int = cell_size

	var rect: Array[Rect2]
	rect.resize(grid_size)

	var rect_position: Vector2
	var rect_size: Vector2 = Vector2(_cell_size, _cell_size)

	var index: int = 0
	for y in grid_tall:
		for x in grid_wide:
			rect_position = Vector2(x, y) * _cell_size + margin_TL				# top-left
			rect[index] = Rect2(rect_position, rect_size)
			index += 1

	return rect


func compute_rect_size(_cell_size: int = -1) -> Array[Rect2]:
	var grid_wide: int = ceili((MyCore.world_size.x - margin_sum.x) / _cell_size)
	var grid_tall: int = ceili((MyCore.world_size.y - margin_sum.y) / _cell_size)
	var grid_size: int = grid_wide * grid_tall

	var rect: Array[Rect2]
	rect.resize(grid_size)

	var rect_position: Vector2
	var rect_size: Vector2 = Vector2(_cell_size, _cell_size)

	var index: int = 0
	for y in grid_tall:
		for x in grid_wide:
			rect_position = Vector2(x, y) * _cell_size + margin_TL				# top-left
			rect[index] = Rect2(rect_position, rect_size)
			index += 1

	return rect


func compute_global() -> PackedVector2Array:									# middle of cell
	var grid: PackedVector2Array
	for index in size:
		# grid[index] = index_to_global(index)									# circular reasoning
		grid.append((Vector2(index % wide, index / wide) + Vector2(0.5, 0.5)) * cell_size + margin_TL)
	return grid


func compute_global_size(_cell_size: int = -1) -> PackedVector2Array:			# middle of cell
	var grid_wide: int = ceili((MyCore.world_size.x - margin_sum.x) / _cell_size)
	var grid_tall: int = ceili((MyCore.world_size.y - margin_sum.y) / _cell_size)
	var grid_size: int = grid_wide * grid_tall

	var grid: PackedVector2Array
	for index in grid_size:
		# grid[index] = index_to_global_size(index, _cell_size)					# circular reasoning
		grid.append((Vector2(index % wide, index / wide) + Vector2(0.5, 0.5)) * _cell_size + margin_TL)
	return grid


func compute_coord() -> PackedVector2Array:
	var grid: PackedVector2Array
	for index in size:
		# grid[index] = index_to_coord(index)									# circular reasoning
		grid.append(Vector2(index % wide, index / wide))
	return grid


func compute_coord_size(_cell_size: int = -1) -> PackedVector2Array:
	var grid_wide: int = ceili((MyCore.world_size.x - margin_sum.x) / _cell_size)
	var grid_tall: int = ceili((MyCore.world_size.y - margin_sum.y) / _cell_size)
	var grid_size: int = grid_wide * grid_tall

	var grid: PackedVector2Array
	for index in grid_size:
		# grid[index] = index_to_coord_size(index, _cell_size)					# circular reasoning
		grid.append(Vector2(index % wide, index / wide))
	return grid


"""
# Cartesian Frame
# en.wikipedia.org/wiki/Cartesian_coordinate_system
"""
func global_to_frame(global: Vector2) -> Vector2:								# TODO: don't snap
	var _cell_size: int = cell_size

	global += Vector2(_cell_size, _cell_size) * 0.5								# add half cell (frame is on corners)
	global -= margin_TL															# global origin

	var frame: Vector2
	frame = global / _cell_size													# global to coords
	frame = frame.floor()														# prevents [-0.1 to -0.9] == 0.0

	frame -= Vector2(wide * 0.5, tall * 0.5)									# (0, 0) at middle
	frame.y *= -1																# y is inverted
	return frame


func global_to_frame_size(global: Vector2, _cell_size: int) -> Vector2:	# TODO: don't snap
	global += Vector2(_cell_size, _cell_size) * 0.5								# add half cell (frame is on corners)
	global -= margin_TL														# global origin

	var frame: Vector2
	frame = global / _cell_size													# global to coords
	frame = frame.floor()														# prevents [-0.1 to -0.9] == 0.0

	frame -= Vector2(wide * 0.5, tall * 0.5)									# (0, 0) at middle
	frame.y *= -1																# y is inverted
	return frame


func frame_to_global(frame: Vector2) -> Vector2:
	var grid_wide: int = wide
	var grid_tall: int = tall

	var _cell_size: int = cell_size

	frame.y *= -1																# y is inverted
	frame += Vector2(grid_wide * 0.5, grid_tall * 0.5)							# (0, 0) at middle

	var global: Vector2
	global = frame * _cell_size													# coord to global
	global += margin_TL														# global origin
	return global


func frame_to_global_size(frame: Vector2, _cell_size: int) -> Vector2:
	var grid_wide: int = ceili((MyCore.world_size.x - margin_sum.x) / _cell_size)
	var grid_tall: int = ceili((MyCore.world_size.y - margin_sum.y) / _cell_size)

	frame.y *= -1																# y is inverted
	frame += Vector2(grid_wide * 0.5, grid_tall * 0.5)							# (0, 0) at middle

	var global: Vector2
	global = frame * _cell_size													# coord to global
	global += margin_TL														# global origin
	return global


func global_snap_to_frame(global: Vector2) -> Vector2:
	var _cell_size: int = cell_size

	global += Vector2(_cell_size, _cell_size) * 0.5								# add half cell (frame is on corners)
	global -= margin_TL														# global origin

	var frame: Vector2
	frame = global / _cell_size													# global to coords
	frame = frame.floor()														# prevents [-0.1 to -0.9] == 0.0

	global = frame * _cell_size													# frame to global
	global += margin_TL														# global origin
	return global


func global_snap_to_frame_size(global: Vector2, _cell_size: int) -> Vector2:
	global += Vector2(_cell_size, _cell_size) * 0.5								# add half cell (frame is on corners)
	global -= margin_TL														# global origin

	var frame: Vector2
	frame = global / _cell_size													# global to coords
	frame = frame.floor()														# prevents [-0.1 to -0.9] == 0.0

	global = frame * _cell_size													# frame to global
	global += margin_TL														# global origin
	return global


func frame_snap_to_frame(frame: Vector2) -> Vector2:
	return frame.round()


""" CUSTOM FUNCTIONS """
func is_border(index: int, border_size: int = 1) -> bool:
	var in_border: bool = false

	var grid_wide: int = wide
	var grid_tall: int = tall

	var coords: Vector2i = index_to_coord(index)
	if coords.x < border_size || coords.y < border_size:						# L or T
		in_border = true
	elif coords.x > grid_wide - border_size - 1:								# R
		in_border = true
	elif coords.y > grid_tall - border_size - 1:								# B
		in_border = true

	return in_border


func is_border_size(index: int, border_size: int = 1, _cell_size: int = -1) -> bool:
	var in_border: bool = false

	var grid_wide: int = ceili((MyCore.world_size.x - margin_sum.x) / _cell_size)
	var grid_tall: int = ceili((MyCore.world_size.y - margin_sum.y) / _cell_size)

	var coords: Vector2i = index_to_coord_size(index, _cell_size)
	if coords.x < border_size || coords.y < border_size:						# L or T
		in_border = true
	elif coords.x > grid_wide - border_size - 1:								# R
		in_border = true
	elif coords.y > grid_tall - border_size - 1:								# B
		in_border = true

	return in_border


func compute_border(border_size: int = 1) -> PackedInt32Array:
	var grid_wide: int = wide
	var grid_tall: int = tall

	var border_array: PackedInt32Array

	var index: int = 0
	for y in grid_tall:
		for x in grid_wide:
			if x < border_size || y < border_size:								# L or T
				border_array.append(index)
			elif x > grid_wide - border_size - 1:								# R
				border_array.append(index)
			elif y > grid_tall - border_size - 1:								# B
				border_array.append(index)
			index += 1

	return border_array


func compute_border_size(border_size: int = 1, _cell_size: int = -1) -> PackedInt32Array:
	var grid_wide: int = ceili((MyCore.world_size.x - margin_sum.x) / _cell_size)
	var grid_tall: int = ceili((MyCore.world_size.y - margin_sum.y) / _cell_size)

	var border_array: PackedInt32Array

	var index: int = 0
	for y in grid_tall:
		for x in grid_wide:
			if x < border_size || y < border_size:								# L or T
				border_array.append(index)
			elif x > grid_wide - border_size - 1:								# R
				border_array.append(index)
			elif y > grid_tall - border_size - 1:								# B
				border_array.append(index)
			index += 1

	return border_array


func compute_border_four(right: int = 1, bottom: int = 1, left: int = 1, top: int = 1) -> PackedInt32Array:
	var grid_wide: int = wide
	var grid_tall: int = tall

	var border_array: PackedInt32Array

	var index: int = 0
	for y in grid_tall:
		for x in grid_wide:
			if x < left || y < top:												# L or T
				border_array.append(index)
			elif x > grid_wide - right - 1:										# R
				border_array.append(index)
			elif y > grid_tall - bottom - 1:									# B
				border_array.append(index)
			index += 1

	return border_array


func compute_border_four_size(right: int = 1, bottom: int = 1, left: int = 1, top: int = 1, _cell_size: int = -1) -> PackedInt32Array:
	var grid_wide: int = ceili((MyCore.world_size.x - margin_sum.x) / _cell_size)
	var grid_tall: int = ceili((MyCore.world_size.y - margin_sum.y) / _cell_size)

	var border_array: PackedInt32Array

	var index: int = 0
	for y in grid_tall:
		for x in grid_wide:
			if x < left || y < top:												# L or T
				border_array.append(index)
			elif x > grid_wide - right - 1:										# R
				border_array.append(index)
			elif y > grid_tall - bottom - 1:									# B
				border_array.append(index)
			index += 1

	return border_array


func _on_world_edit() -> void:
	grid_rect = Rect2(margin_TL, MyCore.world_size - margin_sum)
	wide = ceili((MyCore.world_size.x - margin_sum.x) / cell_size)
	tall = ceili((MyCore.world_size.y - margin_sum.y) / cell_size)
	size = wide * tall

	cell_near = compute_near()													# 0, 1, 2,		3, 4, 5,	6, 7, 8
	cell_near_four = compute_near_four()										# R, D, L, T
	cell_global = compute_global()
	cell_rect = compute_rect()

	on_world_edit.emit()
