class_name MenuWindow
extends Control

# window - 1 (512, 384)
# world - 0 (256, 192)
# Borderless enabled

const START_POSITION: Vector2i = Vector2i(1407.0, 634.0)

var _is_title_held: bool = false
var _is_title_hovered: bool = false
var _mouse_position: Vector2

@onready var _window: Window = get_window()
@onready var _border: = get_child(0) as Control
@onready var _title: = _border.get_child(0) as Control
@onready var _btn_reset := get_child(1) as MyButton
@onready var _btn_close := get_child(2) as MyButton


func _ready() -> void:
	_title.mouse_entered.connect(_on_title_mouse_entered)
	_title.mouse_exited.connect(_on_title_mouse_exited)
	_btn_reset.button_down.connect(reset)
	_btn_close.button_down.connect(close)

	_border.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_title.mouse_filter = Control.MOUSE_FILTER_PASS

	DisplayServer.window_set_position(START_POSITION)


func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey && (event as InputEventKey).pressed:
		var key: Key = (event as InputEventKey).keycode

		if key == KEY_R:
			reset()

		if key == KEY_ESCAPE:
			close()


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse_event: = event as InputEventMouseButton

		if mouse_event.button_index == MOUSE_BUTTON_LEFT:
			if mouse_event.pressed == true && _is_title_hovered == true:
				_is_title_held = true
				_mouse_position = get_global_mouse_position()
				Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
				await get_tree().process_frame									# hides mouse centering
				Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

			elif _is_title_held == true && mouse_event.pressed == false:
				_is_title_held = false
				Input.mouse_mode = Input.MOUSE_MODE_VISIBLE						# unlock mouse
				Input.warp_mouse(_mouse_position * 2.0)							# 2 - difference of world_size & viewport_size

	elif event is InputEventMouseMotion:
		var mouse_event: = event as InputEventMouseMotion

		if _is_title_held == true:
			_window.position += Vector2i(mouse_event.relative) * 2				# 2 - CanvasLayer scale


func enter() -> void:
	pass


func start() -> void:
	pass


func pause() -> void:
	pass


func reset() -> void:
	pass


func death() -> void:
	pass


func close() -> void:
	get_tree().quit()


func _on_title_mouse_entered() -> void:
	_is_title_hovered = true
	_title.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND


func _on_title_mouse_exited() -> void:
	_is_title_hovered = false
	_title.mouse_default_cursor_shape = Control.CURSOR_ARROW
