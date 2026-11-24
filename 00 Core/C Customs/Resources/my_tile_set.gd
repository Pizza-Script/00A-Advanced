@tool
class_name MyTileSet
extends EditorScript															# Ctrl + Shift + X

# duplicated on a "per texture" basis

# add()
# add_alt_modulate(color, coord = Vector2(0, 0))

var _tile_set: TileSet
var _tile_source: TileSetAtlasSource

var _path: String = "z_image.png"
var _size: Vector2i = Vector2i(16, 16)


func _run() -> void:
	_tile_set = TileSet.new()

	add()
	add_alt_modulate("c0cbdc")
	add_alt_modulate("a22633")
	add_alt_modulate("3e8948")
	add_alt_modulate("262b44")
	add_alt_modulate("0099db")

	save()


func add() -> void:
	var script_path: String = get_script().get_path().get_base_dir() + "/"		# load() - absolute paths only
	var texture: Texture2D = load(script_path + _path) as Texture2D				# assign texture to source
	var count: Vector2i = texture.get_size() / (_size as Vector2)

	_tile_source = TileSetAtlasSource.new()										# new source (must use Atlas)
	_tile_source.texture = texture												# assign texture to source
	_tile_source.texture_region_size = _size									# set tile_size in source

	for y in count.y:
		for x in count.x:
			_tile_source.create_tile(Vector2i(x, y))							# create tiles

	_tile_set.add_source(_tile_source)											# add source to tile_set

	print("add - \"%s\"" % [_path])


func add_alt_modulate(color: String, coord: Vector2i = Vector2i(0, 0)) -> void:
	var alt_tile_id: int = _tile_source.create_alternative_tile(coord)	# create alternate tile
	var alt_tile_data: TileData = _tile_source.get_tile_data(coord, alt_tile_id) # get tile_data
	alt_tile_data.modulate = color												# change data of alternate tile

	print("add_alt_modulate - \"%s\"" % [color])


func add_physics_layer(layer: int = -1, mask: int = -1) -> void:				# still need to add each layer manually
	var last_layer_index: int = _tile_set.get_physics_layers_count()

	_tile_set.add_physics_layer()

	if layer != -1:
		_tile_set.set_physics_layer_collision_layer(last_layer_index, layer)
	else:
		_tile_set.set_physics_layer_collision_layer(last_layer_index, 0)

	if mask != -1:
		_tile_set.set_physics_layer_collision_mask(last_layer_index, mask)
	else:
		_tile_set.set_physics_layer_collision_mask(last_layer_index, 0)


func save() -> void:
	_tile_set.tile_size = _size

	var script_path: String = get_script().get_path().get_base_dir() + "/"
	var name: String = _path.split(".")[0]
	ResourceSaver.save(_tile_set, script_path + name + ".tres")

	print("TileSet.save(\"%s.tres\")" % [script_path + name])
