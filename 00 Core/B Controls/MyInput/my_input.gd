class_name MyInput
extends LineEdit

# ALERT: 4.3 to 4.4, something removes focus from modal !!!
# fixed by disabling input and catching mouse click instead

# ALERT: double check js_modal path in "web_clipboard.js"

# .change_text(_string)
# .change_placeholdder(_string)
# .clear_text()

@export var _web_title: String

signal submitted(my_text: String)

@onready var _viewport := get_viewport()


func _ready() -> void:
	if OS.get_name() == "Web":
		focus_mode = FocusMode.FOCUS_NONE
	else:
		focus_entered.connect(_on_focus_entered)
		text_submitted.connect(_on_text_submitted)
		set_process_unhandled_input(false)


func _unhandled_input(event: InputEvent) -> void:
	if OS.get_name() == "Web":
		return

	if event is InputEventMouseButton and (event as InputEventMouseButton).pressed:
		if (event as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT:	# Control > Mouse > Filter > Pass

			if Rect2(Vector2.ZERO, size).has_point(event.position) == false:	# is mouse within control
				_viewport.gui_release_focus()									# [Viewport] release focus on GUI
				set_process_unhandled_input(false)


func _gui_input(event: InputEvent) -> void:
	if OS.get_name() != "Web":
		return

	if event is InputEventMouseButton:
		var mouse_event: = event as InputEventMouseButton

		if mouse_event.pressed == false:
			return

		if mouse_event.button_index == MOUSE_BUTTON_LEFT:
			var _text: String = await WebClipboard.input_text(text, _web_title)
			text = _text
			_on_text_submitted(_text)


func change_text(_text: String) -> void:
	text = _text


func change_placeholdder(_text: String) -> void:
	placeholder_text = _text


func clear_text() -> void:
	text = ""


func _on_focus_entered() -> void:
	set_process_unhandled_input(true)


func _on_text_submitted(my_text: String) -> void:
	_viewport.gui_release_focus()												# remove focus on KEY_ENTER (triggers focus_exited)
	submitted.emit(my_text)
