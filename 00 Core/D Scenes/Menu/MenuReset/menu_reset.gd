class_name MenuReset
extends Control

signal on_reset

@export var start_hidden: bool = true

var _is_held_finished: bool = false

@onready var _btn_reset := get_child(0) as MyButton
@onready var _prg_circle := get_child(1) as MyProgressCircle


func _ready() -> void:
	_btn_reset.button_down.connect(_held_pressed)
	_btn_reset.button_up.connect(_held_released)
	_prg_circle.on_finish.connect(_held_finished)

	_btn_reset.visible = !start_hidden
	_prg_circle.visible = !start_hidden


func _unhandled_key_input(event: InputEvent) -> void:
	var key_event: = event as InputEventKey
	var key: Key = key_event.keycode

	if key == KEY_R:
		if key_event.pressed == true:											# called continuously
			if key_event.echo == false:											# is key just pressed
				_held_pressed()

		elif key_event.pressed == false:										# called once
			_held_released()


func _held_pressed() -> void:
	_prg_circle.start()
	_is_held_finished = false


func _held_released() -> void:
	_prg_circle.stop()															# must always call on release

	if _is_held_finished == true:
		_is_held_finished = false
		reset()


func _held_finished() -> void:
	_is_held_finished = true


func start() -> void:
	_btn_reset.visible = true
	_prg_circle.visible = true


func reset() -> void:
	_btn_reset.visible = false
	_prg_circle.visible = false
	on_reset.emit()


func death() -> void:
	_btn_reset.visible = true
	_prg_circle.visible = true
