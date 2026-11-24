# class_name MyNode																# all about node settings
extends Node

# MyNode.set_index(self, MyNode.Group.BASE)

# MyNode.add_group(self, MyNode.Group.MOB)
# MyNode.is_group(_node, MyNode.Group.MOB)

# MyNode.set_collision_layer(self, MyNode.Layer.MOB, true)
# MyNode.set_collision_mask(self, MyNode.Layer.MOB, true)

# MyNode.mouse_enter()															# for Node2D cursors
# MyNode.mouse_exit()

# if await MyCore.is_mouse_hovered()											# need to await

enum ZIndex																		# lower = front
{
	BASE,

	SHADOW,
	ORB,
	SHOT,
	MOB,
	PLAYER,

	DRAW,
}

enum Group
{
	PLAYER,
	MOB,
	ORB,
	SHOT,
}

enum Layer																		# layers for collision
{																				# 1 enabled by default
	BASE,																		# mask = look | layer = live

	PLAYER,
	MOB,
	EXPLOSION,

	MOUSE,
}

var _group_keys: PackedStringArray = Group.keys()

var _is_checked: bool = true													# check once per frame only
var _is_hovered: bool = false
var _hover_count: int = 0


func set_z_index(node: Node2D, index: ZIndex) -> void:							# for more readable code
	node.z_index = index


func add_group(node: Node2D, group: Group) -> void:
	node.add_to_group(_group_keys[group])


func is_group(node: Node2D, group: Group) -> bool:
	return node.is_in_group(_group_keys[group])


func reset_collision(node: Area2D) -> void:
	# PhysicsServer2D.area_set_collision_layer(node.get_rid(), 0)				# TODO: not working ?
	# PhysicsServer2D.area_set_collision_mask(node.get_rid(), 0)
	node.set_collision_layer_value(1, false)
	node.set_collision_mask_value(1, false)


func set_collision_layer(node: Area2D, layer: Layer, enable: bool = true) -> void: # live in this layer
	node.set_collision_layer_value(layer + 1, enable)							# +1 due to no layer 0


func set_collision_mask(node: Area2D, layer: Layer, enable: bool = true) -> void: # look on this layer
	node.set_collision_mask_value(layer + 1, enable)							# adjuster for PhysicsServer bitwise


func mouse_enter() -> void:														# for overllaping areas
	_hover_count += 1															# enter & exit called simultanously
	_is_checked = false
	_mouse_check.call_deferred()												# check on next frame


func mouse_exit() -> void:
	_hover_count -= 1
	if _hover_count < 0:
		_hover_count = 0

	_is_checked = false
	_mouse_check.call_deferred()


func is_mouse_hovered() -> bool:												# if await MyCore.is_mouse_hovered()
	while _is_checked == false:
		await get_tree().process_frame
	return _is_hovered


func _mouse_check() -> void:
	if _is_checked == true:														# check only once this frame
		return
	_is_checked = true

	if _hover_count == 0:														# check if still hovering
		_is_hovered = false
		Input.set_default_cursor_shape(Input.CursorShape.CURSOR_ARROW)

	elif _is_hovered == false:													# change if unchanged
		_is_hovered = true
		Input.set_default_cursor_shape(Input.CursorShape.CURSOR_POINTING_HAND)
