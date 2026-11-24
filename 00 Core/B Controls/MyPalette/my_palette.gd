@tool
class_name MyPalette
extends Control

# .set_color(index)																# _has_signal = false

# .enable()
# .disable()

signal value_changed(value: Color, index: int)

#region Images
@export_group("Images")
@export var _texture_left: Texture2D = preload("Texture/left.png")
@export var _texture_right: Texture2D = preload("Texture/right.png")
#endregion

@export_group("", "")
@export var _is_enabled: bool = true
@export var _key_shortcuts: bool = false
@export var _title: String = "PALETTE"
@export var _options: Array[Color] = [Color(1, 1, 1, 1), Color(0.1059, 0.1098, 0.2, 1.0),		# for .find()
	Color(0.827451, 0.152941, 0.203922, 1), Color(0.854902, 0.490196, 0.133333, 1),
	Color(0.901961, 0.854902, 0.160784, 1), Color(0.156863, 0.776471, 0.254902, 1),
	Color(0.176471, 0.576471, 0.866667, 1), Color(0.482353, 0.32549, 0.678431, 1)]
@export var _default: int
@export var _label_settings: LabelSettings
@export_tool_button("Create", "FadeDisabled") var create = _create

var _option_index: int
var _option_max: int

@onready var _label: = get_child(0) as Label
@onready var _color_rect: = get_child(1) as ColorRect
@onready var _btn_left: = get_child(2) as MyButton
@onready var _btn_right: = get_child(3) as MyButton


func _ready() -> void:
	_btn_left.button_down.connect(_on_button_left)
	_btn_right.button_down.connect(_on_button_right)

	await get_tree().process_frame
	_layout()
	_values()


func _create() -> void:															# check if nodes exist
	if _label == null:															# create if missing
		_label = Label.new()
		add_child(_label)
		_label.owner = self
		_label.name = "Label"

	if _color_rect == null:
		_color_rect = ColorRect.new()
		add_child(_color_rect)
		_color_rect.owner = self
		_color_rect.name = "ColorRect"

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

	_color_rect.set_anchors_and_offsets_preset(Control.PRESET_CENTER_RIGHT)
	_color_rect.size = Vector2(8.0, 8.0)
	_color_rect.position.x -= 17
	_color_rect.position.y -= 4
	_color_rect.color = _options[_default]

	_btn_left.set_anchors_and_offsets_preset(Control.PRESET_CENTER_RIGHT)
	_btn_left.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_btn_left.position.x -= 15
	_btn_left.texture_normal = _texture_left

	_btn_right.set_anchors_and_offsets_preset(Control.PRESET_CENTER_RIGHT)
	_btn_right.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_btn_right.position.x += 5
	_btn_right.texture_normal = _texture_right


func _values() -> void:
	if _is_enabled == true:
		enable()
	else:
		disable()

	_option_max = _options.size()
	_option_index = _default


func _unhandled_key_input(event: InputEvent) -> void:
	var key_event: = event as InputEventKey
	var key: Key = key_event.keycode

	if key_event.pressed == false:
		return

	if has_focus() == false:													# TODO: get focus
		return

	if key == KEY_LEFT || key == KEY_DOWN:
		_on_button_left()

	elif key == KEY_RIGHT || key == KEY_UP:
		_on_button_right()


func set_color(index: int, _has_signal: bool = false) -> void:
	_color_rect.color = _options[index]
	_option_index = index

	if _has_signal == true:
		value_changed.emit(_options[_option_index], _option_index)


func enable() -> void:
	_is_enabled = true

	_label.modulate = "ffffff"
	_color_rect.modulate = "ffffff"
	_btn_left.enable()
	_btn_right.enable()


func disable() -> void:
	_is_enabled = false

	_label.modulate = "ffffff4b"
	_color_rect.modulate = "ffffff4b"
	_btn_left.disable()
	_btn_right.disable()


func _on_button_left() -> void:
	_option_index = wrapi(_option_index - 1, 0, _option_max)

	_color_rect.color = _options[_option_index]
	value_changed.emit(_options[_option_index], _option_index)


func _on_button_right() -> void:
	_option_index = wrapi(_option_index + 1, 0, _option_max)

	_color_rect.color = _options[_option_index]
	value_changed.emit(_options[_option_index], _option_index)
