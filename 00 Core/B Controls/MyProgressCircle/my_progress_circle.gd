class_name  MyProgressCircle
extends TextureProgressBar

# "hold-down" action circle interface
# .start()
# .stop()

# BUTTON CONNECT
# _btn_reset.button_down.connect(func(): _prg_circle.start())
# _btn_reset.button_up.connect(func(): _prg_circle.stop())

signal on_finish
signal on_reset

@export var _instant_cancel: bool = false
@export var _key_shortcut: bool = false
@export var _key_pressed: Key = KEY_R
@export var _held_timer: float = 1.00
@export var _held_delay: float = 0.10
@export var _default_color: Color = "ffffff"
@export var _finish_color: Color = "e43b44"

var _is_held: bool = false
var _is_finished: bool = false													# for single on_finish emit()
var _held_total: float = 0.0
var _held_spent: float = 0.0


func _ready() -> void:
	fill_mode = FillMode.FILL_CLOCKWISE

	_held_total = _held_timer + _held_delay

	set_process_unhandled_key_input(_key_shortcut)


func _unhandled_key_input(event: InputEvent) -> void:
	var key_event: = event as InputEventKey
	var key: Key = key_event.keycode

	if key == _key_pressed:
		if key_event.pressed == true:											# called continuously
			if key_event.echo == false:											# is key just pressed
				start()

		elif key_event.pressed == false:										# called once
			stop()


func start() -> void:
	_is_held = true
	_is_finished = false
	set_process(true)


func stop() -> void:
	_is_held = false
	self_modulate = _default_color


func _process(delta: float) -> void:
	if _is_held == true && _is_finished == false:
		_held_spent += delta											# timer up
		if _held_spent >= _held_total:
			_held_spent = _held_total
			_is_finished = true
			on_finish.emit()
			self_modulate = _finish_color

	elif _is_held == false && _instant_cancel == false:
		if _held_spent > _held_timer:
			_held_spent = _held_timer

		_held_spent -= delta											# timer down
		if _held_spent < 0.0:
			_held_spent = 0.0
			on_reset.emit()
			set_process(false)

	elif _is_held == false && _instant_cancel == true:					# no cooldown
		_held_spent = 0.0
		on_reset.emit()
		set_process(false)

	value = (_held_spent / _held_timer) * 100


#region Button Hold - Release
"""
var _is_held_finished: bool = false

func _ready() -> void:
	_prg_circle.on_finish.connect(_held_finished)
	_btn_reset.button_down.connect(_held_pressed)
	_btn_reset.button_up.connect(_held_released)


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
"""
#endregion
