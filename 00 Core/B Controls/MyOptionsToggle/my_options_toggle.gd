@tool
class_name MyOptionsToggle
extends Control

# .enable()
# .disable()
# .set_options(options: PackedStringArray)

# .update_value(index: int)

signal value_changed(value: int)

enum ScrollWidth
{
	LABEL,
	FULL,
}

@export var _is_enabled: bool = true
@export var _title: String = "OPTION"
@export var _options: PackedStringArray = ["INDEX", "LIFETIME"]
@export var _default: int = 0
@export var _label_width: int = 64
@export var _label_settings: LabelSettings
@export_tool_button("Create", "FadeDisabled") var create = _create

var _option_index: int

@onready var _label: = get_child(0) as Label
@onready var _button: = get_child(1) as MyButtonLabel


func _ready() -> void:
	_button.button_down.connect(_on_button_down)

	await get_tree().process_frame
	_layout()
	_values()


func _create() -> void:															# check if nodes exist
	if _label == null:															# create if missing
		_label = Label.new()
		add_child(_label)
		_label.owner = self
		_label.name = "Label"

	if _button == null:
		_button = MyButtonLabel.new()
		add_child(_button)
		_button.owner = self
		_button.name = "Button"

	await get_tree().process_frame
	_layout()
	_values()


func _layout() -> void:															# default values
	_label.set_anchors_and_offsets_preset(Control.PRESET_CENTER_LEFT)
	_label.label_settings = _label_settings
	_label.offset_transform_enabled = true
	_label.offset_transform_position.x = -1.0
	_label.text = _title

	_button.set_anchors_and_offsets_preset(Control.PRESET_RIGHT_WIDE)
	_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_button.set_alignment_x(HorizontalAlignment.HORIZONTAL_ALIGNMENT_RIGHT)
	_button.position.x -= _label_width - _button.size.x							# target_size - current_size
	_button.size.x = _label_width

	_button.set_label(_options[_default])


func _values() -> void:
	if _is_enabled == true:
		enable()
	else:
		disable()

	_option_index = _default


func update_value(index: int, _has_signal: bool = false) -> void:
	_option_index = index

	_button.set_label(_options[_option_index])
	if _has_signal == true:
		value_changed.emit(_option_index)


func set_options(options: PackedStringArray) -> void:
	_options = options
	_values()


func enable() -> void:
	_label.modulate = "ffffff"
	_button.modulate = "ffffff"
	_button.enable()


func disable() -> void:
	_label.modulate = "ffffff4b"
	_button.modulate = "ffffff4b"
	_button.disable()


func menu_toggle() -> void:
	_option_index += 1
	if _option_index == _options.size():
		_option_index = 0

	_button.set_label(_options[_option_index])
	value_changed.emit(_option_index)


func _on_button_down() -> void:
	menu_toggle()
