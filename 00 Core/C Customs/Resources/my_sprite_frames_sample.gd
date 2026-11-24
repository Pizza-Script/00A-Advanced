@tool
class_name SpriteFramesTool
extends MySpriteFrames															# Ctrl + Shift + X

# set_file(name, size, fps, loop
# add_anim(name, row, fps, loop)
# add_anim(name)
# save(name)


func _run() -> void:
	file = "chicken_S.png"
	size = Vector2i(16, 16)
	fps = 8.3
	loop = true

	set_file(file, size, fps, loop)
	add_anim("idle_face")
	add_anim("idle_back")
	add_anim("idle_side")

	save()
