class_name MenuStart
extends Control

signal on_start																	# button triggers signal

var _is_started: bool

@onready var _btn_start := get_child(0) as MyButton
@onready var _lbl_middle := get_child(1) as Label


func _ready() -> void:
	_btn_start.button_down.connect(_on_start_pressed)

	death()


func _unhandled_key_input(event: InputEvent) -> void:
	# if _is_started == true:
	# 	return

	var key_event: = event as InputEventKey
	var key: Key = key_event.keycode

	if key_event.pressed == true:
		if key == KEY_SPACE:													# game start
			start()


func start() -> void:															# new game
	_btn_start.visible = false
	_lbl_middle.visible = false

	on_start.emit()																# signal on button press
	_is_started = true


func death() -> void:
	_btn_start.visible = true
	_lbl_middle.visible = true
	_is_started = false


func _on_start_pressed() -> void:
	if _is_started == false:
		start()
