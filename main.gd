class_name Main
extends Node2D

# @export var _menu: MenuButtons
# @export var _texture: Texture2D

# @onready var _sprite: = get_child(0) as Sprite2D


func _ready() -> void:
	pass


func _unhandled_key_input(event: InputEvent) -> void:
	var key_event: = event as InputEventKey
	var key: Key = key_event.keycode

	if key_event.pressed == false:												# on press down only
		return

	if key_event.echo == true:													# trigger only once
		return

	if key == KEY_T:
		pass


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse_event: = event as InputEventMouseButton

		if mouse_event.pressed == false:
			return

		if mouse_event.button_index == MOUSE_BUTTON_LEFT:
			pass


func _start() -> void:															# new game
	pass


func _sleep() -> void:															# pause (AnimatedSprite2D conflict)
	pass


func _awake() -> void:															# unpause
	pass


func _reset() -> void:															# reset
	pass


func _death() -> void:															# gameover
	pass
