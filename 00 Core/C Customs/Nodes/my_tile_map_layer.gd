class_name MyTileMapLayer
extends TileMapLayer

# Type A - BASE
	# MANY base tile, NO alt tiles
	# tileset can have gaps, index to Vector2i is not reliable
	# index is top to bottom first (uses Vector2i as ID)

# Type B - ALT
	# ONE base Tile, MANY alt tiles
	# alternative_id will not be updated on edit / delete
	# index_2 will remain index_2 even if index_1 is deleted

# NOTE: no longer uses MyGrid
	# now uses TileSet.tile_size

# .get_coord_type(v2i)
# .get_xy_type(x, y)
# .get_index_type(i)
# .get_global_type(v2)

# .set_coord_type(v2i, type, Rotate)
# .set_xy_type(x, y, type, Rotate)
# .set_index_type(i, type, Rotate)
# .set_global_type(v2, type, Rotate)
# .set_world_type(type, Rotate)

# .delete_coord(v2i)
# .delete_xy(x, y)
# .delete_index(i)
# .delete_global(v2)
# .delete_world()

enum Rotate {
	RIGHT,
	DOWN,
	LEFT,
	TOP,
}

var _is_base: bool = true

var wide: int
var tall: int
var size: int

var _tile_set_source_id: int
var _tile_set_source: TileSetSource

var _tile_id_array: Array[Vector2i]												# base tile ID is Vector2i
var _tile_id_array_alt: Array[int]												# NOTE: tile ID is TOP-DOWN, not LR


func _ready() -> void:
	_tile_set_source_id = tile_set.get_source_id(0)								# get ID of index
	_tile_set_source = tile_set.get_source(_tile_set_source_id)					# get TileSetSource
	var _tile_count: int = _tile_set_source.get_tiles_count()

	if _tile_count != 1:														# Type A BASE (many base tile)
		var max_x: int
		var coord_x: int = 0
		var coord_y: int = 0

		_tile_id_array.resize(_tile_count)
		for index in _tile_count:												# from top to bottom (not L to R)
			# _tile_id_array[index] = _tile_set_source.get_tile_id(index)		# returns v2i coords
			coord_x = _tile_set_source.get_tile_id(index).x
			if coord_x > max_x:
				max_x = coord_x

		coord_x = 0																# adjust list of ID (L to R)
		for index in _tile_count:												# NOTE: tile atlas can't have spaces
			_tile_id_array[index] = Vector2i(coord_x, coord_y)
			coord_x += 1
			if coord_x > max_x:
				coord_x = 0
				coord_y += 1

	elif _tile_count == 1:														# Type B ALT (one base tile)
		_is_base = false
		_tile_count = _tile_set_source.get_alternative_tiles_count(Vector2i(0, 0))

		_tile_id_array_alt.resize(_tile_count)									# 0 is base tile
		for index in _tile_count:
			_tile_id_array_alt[index] = _tile_set_source.get_alternative_tile_id(Vector2i(0, 0), index)

	wide = ceili((MyCore.world_size.x - MyGrid.margin_sum.x) / tile_set.tile_size.x)
	tall = ceili((MyCore.world_size.y - MyGrid.margin_sum.y) / tile_set.tile_size.y)
	size = wide * tall

	MyCore.on_world_edit.connect(_on_world_edit)


# GET
func get_coord_type(coord: Vector2i) -> int:
	if _is_base == true:
		return _tile_id_array.find(get_cell_atlas_coords(coord))
	else:
		return _tile_id_array_alt.find(get_cell_alternative_tile(coord))


func get_xy_type(x: int, y: int) -> int:
	return get_coord_type(Vector2i(x, y))


func get_index_type(index: int) -> int:
	return get_coord_type(Vector2i(index % wide, index / tall))


func get_global_type(global: Vector2) -> int:
	return get_coord_type(local_to_map(to_local(global)))


# SET
func set_coord_type(coord: Vector2i, type: int, _rotate: Rotate = Rotate.RIGHT) -> void:
	var alt_rotate: int
	if _is_base == true:
		alt_rotate = 0
	else:
		alt_rotate = _tile_id_array_alt[type]

	if _rotate == Rotate.DOWN:													# docs.godotengine.org/en/stable/classes/class_tilesetatlassource.html#constants
		alt_rotate = alt_rotate | TileSetAtlasSource.TRANSFORM_FLIP_H | TileSetAtlasSource.TRANSFORM_TRANSPOSE
	elif _rotate == Rotate.LEFT:
		alt_rotate = alt_rotate | TileSetAtlasSource.TRANSFORM_FLIP_H | TileSetAtlasSource.TRANSFORM_FLIP_V
	elif _rotate == Rotate.TOP:
		alt_rotate = alt_rotate | TileSetAtlasSource.TRANSFORM_FLIP_V | TileSetAtlasSource.TRANSFORM_TRANSPOSE

	if _is_base == true:
		set_cell(coord, _tile_set_source_id, _tile_id_array[type], alt_rotate)	# (coord, source_id, atlas_coord, alternative_id)
	else:
		set_cell(coord, _tile_set_source_id, Vector2i(0, 0), alt_rotate)


func set_xy_type(x: int, y: int, type: int, _rotate: Rotate = Rotate.RIGHT) -> void:
	set_coord_type(Vector2i(x, y), type, _rotate)


func set_index_type(index: int, type: int, _rotate: Rotate = Rotate.RIGHT) -> void:
	set_coord_type(Vector2i(index % wide, index / wide), type, _rotate)


func set_global_type(global: Vector2, type: int, _rotate: Rotate = Rotate.RIGHT) -> void:
	set_coord_type(local_to_map(to_local(global)), type, _rotate)


func set_world_type(type: int, _rotate: Rotate = Rotate.RIGHT) -> void:
	print(tall)
	print(wide)
	for index in (wide * tall):
		set_index_type(index, type, _rotate)


# DELETE
func delete_coord(coord: Vector2i) -> void:
	set_cell(coord, -1, Vector2i(-1, -1), -1)


func delete_xy(x: int, y: int) -> void:
	delete_coord(Vector2i(x, y))


func delete_index(index: int) -> void:
	delete_coord(Vector2i(index % wide, index / wide))


func delete_global(global: Vector2) -> void:
	delete_coord(local_to_map(to_local(global)))


func delete_world() -> void:
	clear()


func _on_world_edit() -> void:
	wide = ceili((MyCore.world_size.x - MyGrid.margin_sum.x) / tile_set.tile_size.x)
	tall = ceili((MyCore.world_size.y - MyGrid.margin_sum.y) / tile_set.tile_size.y)
	size = wide * tall
