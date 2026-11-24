@tool
class_name MySpriteFrames
extends EditorScript															# Ctrl + Shift + X

# one extended script per texture
# each frame is equally sized
# Frame Duration not yet supported
# must reload project after saving file 										# [github.com/godotengine/godot/issues/30302]

# set_file(name, size, fps, loop
# add_anim(name, row, fps, loop)
# add_anim(name)
# save(name)

var _sprite_frames: SpriteFrames = SpriteFrames.new()
var _image: Image
var _count: int																	# columns/frames per row
var _row: int																	# automatically increment

var file: String
var size: Vector2i = Vector2i(16, 16)
var fps: float = 8.3
var loop: bool = true


func save(_name: String = file) -> void:
	_sprite_frames.remove_animation("default")									# remove "default" animation

	var script: String = get_script().get_path().get_base_dir() + "/"			# load() - absolute paths only
	_name = _name.split(".")[0]													# remove extension
	ResourceSaver.save(_sprite_frames, script + _name + ".tres")


func add_anim(name: String, row_count: int = 1, _fps: float = fps, is_looping: bool = loop) -> void:
	if file == "":
		print("must set file")
		return

	if _sprite_frames.has_animation(name):										# add_anim animation
		_sprite_frames.remove_animation(name)
	_sprite_frames.add_animation(name)

	var rect: Rect2i = Rect2i(Vector2i.ZERO, size)
	var image: Image
	var texture: Texture2D

	for i in row_count:															# if multiple rows
		for index in _count:													# add_anim frames
			rect.position = Vector2i(index, _row) * size
			image = _image.get_region(rect)

			if image.is_invisible() == true:									# empty frame
				break															# end loop

			texture = ImageTexture.create_from_image(image)
			_sprite_frames.add_frame(name, texture)
		_row += 1

	_sprite_frames.set_animation_speed(name, _fps)								# settings
	_sprite_frames.set_animation_loop(name, is_looping)
	print("MySpriteFrames.add_anim(\"%s\")" % [name])


func set_file(file_name: String = file, _size: Vector2i = size, _fps: float = fps, is_looping: bool = loop) -> void:
	var script: String = get_script().get_path().get_base_dir() + "/"			# load() - absolute paths only
	_image = (load(script + file_name) as Texture2D).get_image()
	_count = _image.get_size().x / _size.x
	_row = 0

	fps = _fps
	loop = is_looping
