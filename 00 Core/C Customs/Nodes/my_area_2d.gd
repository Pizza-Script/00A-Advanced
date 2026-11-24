@tool
class_name MyArea2D
extends Area2D

@export_tool_button("Apply", "ImportCheck") var apply = _apply


func _apply() -> void:
	var _collision: = CollisionShape2D.new()
	var _shape: = CircleShape2D.new()
	_shape.radius = 8.0
	_collision.shape = _shape
	add_child(_collision)														# must add_child_first
	_collision.owner = get_tree().edited_scene_root								# Owner must be an ancestor in the tree
	_collision.name = "CollisionShape2D"										# must add first, before name change

	var _sprite: = MySprite2D.new()
	add_child(_sprite)
	_sprite.owner = get_tree().edited_scene_root
	_sprite.name = "Sprite2D"
	_sprite.my_apply()

	set_script(null)															# remove script after
