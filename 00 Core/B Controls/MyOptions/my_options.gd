@tool
class_name MyOptions
extends Control

# .enable()
# .disable()
# .set_options(options: PackedStringArray)

# .button_left()																# _has_signal = false
# .button_right()
# .update_value(index: int)

signal value_changed(value: int)

#region Images
@export_group("Images")
@export var _texture_left: Texture2D = preload("Texture/left.png")
@export var _texture_right: Texture2D = preload("Texture/right.png")
#endregion

@export_group("", "")
@export var _is_enabled: bool = true
@export var _key_shortcuts: bool = false
@export var _title: String = "OPTION"
@export var _options: Array[String] = ["INDEX", "LIFETIME"]
@export var _default: int = 0
@export var _label_settings: LabelSettings
@export_tool_button("Create", "FadeDisabled") var create = _create

var _option_index: int
var _option_max: int

@onready var _label: = get_child(0) as Label
@onready var _lbl_options: = get_child(1) as Label
@onready var _btn_left: = get_child(2) as MyButton
@onready var _btn_right: = get_child(3) as MyButton


func _ready() -> void:
	_btn_left.button_down.connect(button_left.bind(true))
	_btn_right.button_down.connect(button_right.bind(true))

	await get_tree().process_frame
	_layout()
	_values()


func _create() -> void:															# check if nodes exist
	if _label == null:															# create if missing
		_label = Label.new()
		add_child(_label)
		_label.owner = self
		_label.name = "Label"

	if _lbl_options == null:
		_lbl_options = Label.new()
		add_child(_lbl_options)
		_lbl_options.owner = self
		_lbl_options.name = "Options"

	if _btn_left == null:
		_btn_left = MyButton.new()
		add_child(_btn_left)
		_btn_left.owner = self
		_btn_left.name = "BtnLeft"

	if _btn_right == null:
		_btn_right = MyButton.new()
		add_child(_btn_right)
		_btn_right.owner = self
		_btn_right.name = "BtnRight"

	await get_tree().process_frame
	_layout()
	_values()


func _layout() -> void:															# default values
	_label.set_anchors_and_offsets_preset(Control.PRESET_CENTER_LEFT)
	_label.label_settings = _label_settings
	_label.position.x = -1.0
	_label.text = _title

	_lbl_options.set_anchors_and_offsets_preset(Control.PRESET_CENTER_RIGHT)
	_lbl_options.label_settings = _label_settings
	_lbl_options.pivot_offset_ratio = Vector2(1.0, 0.5)
	_lbl_options.position.x -= 64.0 - _lbl_options.size.x						# target_size - current_size
	_lbl_options.position.y -= 1.0
	_lbl_options.size.x = 64.0
	_lbl_options.text = _options[_default]

	_btn_left.set_anchors_and_offsets_preset(Control.PRESET_CENTER_RIGHT)
	_btn_left.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_btn_left.position.x -= 51
	_btn_left.position.y -= 1
	_btn_left.texture_normal = _texture_left

	_btn_right.set_anchors_and_offsets_preset(Control.PRESET_CENTER_RIGHT)
	_btn_right.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_btn_right.position.x += 5
	_btn_right.position.y -= 1
	_btn_right.texture_normal = _texture_right


func _values() -> void:
	if _is_enabled == true:
		enable()
	else:
		disable()

	_option_max = _options.size()
	_option_index = _default


func _unhandled_key_input(event: InputEvent) -> void:
	if _key_shortcuts == false:
		return

	var key_event: = event as InputEventKey
	var key: Key = key_event.keycode

	if has_focus() == false:													# TODO: get focus
		return

	if key_event.pressed == false:												# on press down only
		return

	if key_event.echo == true:													# trigger only once
		return

	if key == KEY_TAB:
		button_right()

	elif key == KEY_RIGHT || key == KEY_UP:
		button_right()

	elif key == KEY_LEFT || key == KEY_DOWN:
		button_left()


func button_left(_has_signal: bool = false) -> int:
	_option_index = wrapi(_option_index - 1, 0, _option_max)

	_lbl_options.text = _options[_option_index]
	if _has_signal == true:
		value_changed.emit(_option_index)

	return _option_index


func button_right(_has_signal: bool = false) -> int:
	_option_index = wrapi(_option_index + 1, 0, _option_max)

	_lbl_options.text = _options[_option_index]
	if _has_signal == true:
		value_changed.emit(_option_index)

	return _option_index


func update_value(index: int, _has_signal: bool = false) -> void:
	_option_index = index

	_lbl_options.text = _options[_option_index]
	if _has_signal == true:
		value_changed.emit(_option_index)


func set_options(options: PackedStringArray) -> void:
	_options = options
	_values()


func enable() -> void:
	_label.modulate = "ffffff"
	_lbl_options.modulate = "ffffff"
	_btn_left.enable()
	_btn_right.enable()


func disable() -> void:
	_label.modulate = "ffffff4b"
	_lbl_options.modulate = "ffffff4b"
	_btn_left.disable()
	_btn_right.disable()
