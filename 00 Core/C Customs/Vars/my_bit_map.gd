class_name MyBitmap
extends BitMap

# var _bitmap: = MyBitMap.new(_wide, _tall)

# .resize(v2i)
# .resize_i(i)
# .resize_xy(x, y)

# .get_xy_bit(x, y)
# .get_index_bit(i)
# .get_coord_bit(v2)

# .set_xy_bit(x, y, bit)
# .set_index_bit(i, bit)
# .set_coord_bit(v2, bit)

# .flip_xy_bit(x, y)															# no native flip_bit
# .flip_index_bit(i)
# .flip_coord_bit(v2)

# .clear()
# .get_size()																	# native method		v2i dimensions
# .get_texture()
# .get_true_bit_count()															# native method
# .get_false_bit_count()
# .print_bitmap(true)

# .flip_global_bit(v2, size)
# .set_global_bit(v2, size, bit)
# .get_global_bit(v2, size)
# .global_to_coord(v2, size)

var _wide: int = 0
var _tall: int = 0


func _init(wide: int, tall: int) -> void:										# avoids the need to use .create()
	_wide = wide
	_tall = _tall
	create(Vector2i(wide, tall))


# SIZE
@warning_ignore("native_method_override")										# [ERROR] can't override native function
func resize(size: Vector2i) -> void:
	super(size)
	_wide = size.x
	_tall = size.x


func resize_i(size: int) -> void:
	_wide = size
	_tall = size
	resize(Vector2i(size, size))


func resize_xy(wide: int, tall: int) -> void:
	_wide = wide
	_tall = tall
	resize(Vector2i(wide, tall))


# GET
func get_xy_bit(x: int, y: int) -> bool:
	return get_bit(x, y)


func get_index_bit(index: int) -> bool:
	return get_bit(index % _wide, index / _wide)


func get_coord_bit(coord: Vector2i) -> bool:
	return get_bitv(coord)

# SET
func set_xy_bit(x: int, y: int, bit: bool) -> void:
	set_bit(x, y, bit)


func set_index_bit(index: int, bit: bool) -> void:
	set_bit(index % _wide, index / _wide, bit)


func set_coord_bit(coord: Vector2i, bit: bool) -> void:
	set_bitv(coord, bit)


# FLIP
func flip_xy_bit(x: int, y: int) -> void:
	set_bit(x, y, not get_bit(x, y))


func flip_index_bit(index: int) -> void:
	flip_xy_bit(index % _wide, index / _wide)


func flip_coord_bit(coord: Vector2i) -> void:
	flip_xy_bit(coord.x, coord.y)


# OTHERS

func clear() -> void:
	set_bit_rect(Rect2i(Vector2i(0, 0), Vector2i(_wide, _tall)), false)


func get_texture() -> Texture2D:
	var image: Image = convert_to_image()
	return ImageTexture.create_from_image(image)


func get_false_bit_count() -> int:
	return (_wide * _tall) - get_true_bit_count()


func print_bitmap(detailed: bool = false) -> void:
	var label: String = ""
	print("")

	if detailed == true:
		print("Wide: %s - Tall: %s" % [_wide, _tall])

		var top_label: String = ""
		for x in _wide:
			label = "%02d " % x
			if x % 10 == 0:
				top_label += ". "
			else:
				top_label += label[1] + " "
		print(top_label)
		print("")

	var bit: bool
	var row_print: String
	for y in _tall:
		row_print = ""
		for x in _wide:
			bit = get_bit(x, y)
			if bit == true:
				row_print += "x "
			elif bit == false:
				row_print += "- "

		if detailed == true:
			if y % 10 == 0:
				row_print += " ."
			else:
				label = "%02d" % y
				row_print += " " + label[1]
		print(row_print)


# GLOBAL
func global_to_coord(global: Vector2, size: int) -> Vector2i:					# based on MyGrid logic
	var cell_size: Vector2 = Vector2(size, size)
	return Vector2i(((global / cell_size) + Vector2(0.00005, 0.00005)).floor())


func get_global_bit(global: Vector2, size: int) -> bool:
	var coord: Vector2i = global_to_coord(global, size)
	return get_bitv(coord)


func set_global_bit(global: Vector2, size: int, bit: bool) -> void:
	var coord: Vector2i = global_to_coord(global, size)
	set_bitv(coord, bit)


func flip_global_bit(global: Vector2, size: int) -> void:
	var coord: Vector2i = global_to_coord(global, size)
	flip_xy_bit(coord.x, coord.y)
