class_name MyHealthHalf
extends HBoxContainer

@export var _texture_full: Texture2D
@export var _texture_half: Texture2D
@export var _texture_base: Texture2D

var _health_now: int
var _health_max: int

var _health_array: Array[TextureRect]
var _health_new: TextureRect

"""
func _ready() -> void:
	update_max(5)


func _unhandled_key_input(event: InputEvent) -> void:
	var key_event: = event as InputEventKey
	var key: Key = key_event.keycode

	if key_event.pressed == false:
		return

	if key == KEY_T:
		update(_health_now - 1)
	if key == KEY_Y:
		update(_health_now + 1)
"""


func update_max(max: int) -> void:
	var array_size: int = _health_array.size()
	var half_count: int = max * 0.5
	var is_even: bool = max % 2 == 0

	if is_even == false:
		half_count += 1

	if half_count > array_size:													# max larger than current array
		for i in max - array_size:												# add new hearts
			_health_new = TextureRect.new()
			_health_new.name = "Health%02d" % _health_array.size()
			_health_new.texture = _texture_full
			_health_array.append(_health_new)
			add_child(_health_new)

	if half_count != _health_max * 0.5:											# new max
		for index in _health_array.size():
			if index < half_count:
				_health_array[index].visible = true								# show hearts at max
			else:
				_health_array[index].visible = false							# hide others

		if is_even == false:
			_health_array[half_count].visible = true

	_health_max = max


func update(now: int) -> void:
	if now > _health_max:                                                       # limit to max only
		now = _health_max

	_health_now = now

	var index: int = 0
	for i in _health_max:
		if i % 2 == 1:
			continue

		if i < _health_now:
			if _health_now % 2 == 1 && i == _health_now - 1:
				_health_array[index].texture = _texture_half
			else:
				_health_array[index].texture = _texture_full
		else:
			_health_array[index].texture = _texture_base

		index += 1
