class_name MyLabelCopy
extends Label

# copy on click

@export var _copy_delay: float = 0.5
@export var copy_message: String = "COPIED!"
@export var copy_text: String = ""												# if empty, copy Label.text
	# useful if text to copy & text to show are different

var _tween: Tween
var _text_old: String


func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	mouse_filter = Control.MOUSE_FILTER_PASS


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse_event: = event as InputEventMouseButton

		if mouse_event.pressed == false:
			return

		if mouse_event.button_index == MOUSE_BUTTON_LEFT:
			_copied()


func _copied() -> void:
	if copy_text.is_empty():
		DisplayServer.clipboard_set(text)
	else:
		DisplayServer.clipboard_set(copy_text)

	if text != copy_message:
		_text_old = text

	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_callback(func(): text = copy_message)
	_tween.tween_interval(_copy_delay)
	_tween.tween_callback(func(): text = _text_old)


func _on_mouse_entered() -> void:
	modulate = "dcdcdc"


func _on_mouse_exited() -> void:
	modulate = "ffffff"
