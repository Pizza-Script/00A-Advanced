@tool
class_name MyButtonLabel
extends TextureButton

# used by other

signal held
# signal pressed
# signal button_down
# signal button_up

# .enable()
# .disable()

# .set_label(text: String)
# .set_alignment_x(HorizontalAlignment)
# .set_alignment_y(VerticalAlignment)

@export var _is_enabled: bool = true
@export var _title: String = "LABEL"
@export var _alignment_x: = HorizontalAlignment.HORIZONTAL_ALIGNMENT_CENTER
@export var _alignment_y: = VerticalAlignment.VERTICAL_ALIGNMENT_CENTER
@export var _label_settings: LabelSettings
@export_tool_button("Create", "FadeDisabled") var create = _create

var _held_spent: float
var _held_timer: float = 0.2

@onready var _label: = get_child(0) as Label


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS										# can press when paused
	focus_mode = Control.FOCUS_NONE												# avoid focus highlight

	set_process(false)
	await get_tree().process_frame
	_layout()
	_values()


func _create() -> void:															# check if nodes exist
	if _label == null:															# create if missing
		_label = Label.new()
		add_child(_label)
		_label.owner = self
		_label.name = "Label"

	await get_tree().process_frame
	_layout()
	_values()


func _layout() -> void:															# default values
	_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_label.label_settings = _label_settings
	_label.offset_transform_enabled = true
	_label.offset_transform_position.x = -1.0

	_label.text = _title
	_label.horizontal_alignment = _alignment_x
	_label.vertical_alignment = _alignment_y


func _values() -> void:
	if _is_enabled == true:
		enable()
	else:
		disable()


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


func set_label(text: String) -> void:
	_label.text = text
	_title = text


func set_alignment_x(alignment: HorizontalAlignment) -> void:
	_label.horizontal_alignment = alignment
	_alignment_x = alignment


func set_alignment_y(alignment: VerticalAlignment) -> void:
	_label.vertical_alignment = alignment
	_alignment_y = alignment


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
