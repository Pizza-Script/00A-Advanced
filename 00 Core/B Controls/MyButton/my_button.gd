@tool
class_name MyButton
extends TextureButton

# used by other

signal held
# signal pressed
# signal button_down
# signal button_up

# .enable()
# .disable()

var _held_spent: float
var _held_timer: float = 0.2


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS										# can press when paused
	focus_mode = Control.FOCUS_NONE												# avoid focus highlight

	set_process(false)

	enable()


func _process(delta: float) -> void:
	_held_spent += delta
	if _held_spent >= _held_timer:
		_held_spent = 0.0

		held.emit()


func enable() -> void:
	disabled = false
	modulate = "ffffff"
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

	if is_connected("mouse_entered", _on_mouse_entered) == false:				# avoid connecting again
		mouse_entered.connect(_on_mouse_entered)
		mouse_exited.connect(_on_mouse_exited)
		button_down.connect(_on_button_down)
		button_up.connect(_on_button_up)


func disable() -> void:
	disabled = true																# NOTE: while held down
	await get_tree().process_frame												# emits button_up on disable
	modulate = "ffffff4b"
	mouse_default_cursor_shape = Control.CURSOR_FORBIDDEN

	if is_connected("mouse_entered", _on_mouse_entered) == true:
		mouse_entered.disconnect(_on_mouse_entered)
		mouse_exited.disconnect(_on_mouse_exited)
		button_down.disconnect(_on_button_down)
		button_up.disconnect(_on_button_up)


func _on_mouse_entered() -> void:
	modulate = "dcdcdc"															# mouse hover


func _on_mouse_exited() -> void:
	if button_pressed == false:													# mouse held on exit (stay clicked)
		modulate = "ffffff"


func _on_button_down() -> void:
	modulate = "c0c0c0"															# mouse click

	set_process(true)
	_held_spent = -0.4															# double delay before first


func _on_button_up() -> void:
	if is_hovered() == true:
		modulate = "dcdcdc"														# mouse released (hovered)
	else:
		modulate = "ffffff"														# mouse released (not hovered)

	set_process(false)
	_held_spent = 0.0
