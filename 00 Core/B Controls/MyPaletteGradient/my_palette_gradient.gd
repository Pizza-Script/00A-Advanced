@tool
class_name MyPaletteGradient
extends Control

# .set_color_a(index)															# _has_signal = false
# .set_color_b(index)															# _has_signal = false

# .enable()
# .disable()

signal value_changed(value_a: Color, value_b: Color, index_a: int, index_b: int)

#region Images
@export_group("Images")
@export var _texture_left: Texture2D = preload("Texture/left.png")
@export var _texture_right: Texture2D = preload("Texture/right.png")
#endregion

@export_group("", "")
@export var _is_enabled: bool = true
@export var _title: String = "GRADIENT"
@export var _options: Array[Color] = [Color(1, 1, 1, 1), Color(0.1059, 0.1098, 0.2, 1.0),		# for .find()
	Color(0.827451, 0.152941, 0.203922, 1), Color(0.854902, 0.490196, 0.133333, 1),
	Color(0.901961, 0.854902, 0.160784, 1), Color(0.156863, 0.776471, 0.254902, 1),
	Color(0.176471, 0.576471, 0.866667, 1), Color(0.482353, 0.32549, 0.678431, 1)]
@export var _default_a: int
@export var _default_b: int
@export var _label_settings: LabelSettings
@export_tool_button("Create", "FadeDisabled") var create = _create

var _option_index_a: int
var _option_index_b: int
var _option_max: int

@onready var _label: = get_child(0) as Label
@onready var _color_a: = get_child(1) as ColorRect
@onready var _btn_left_a: = get_child(2) as MyButton
@onready var _btn_right_a: = get_child(3) as MyButton
@onready var _color_b: = get_child(4) as ColorRect
@onready var _btn_left_b: = get_child(5) as MyButton
@onready var _btn_right_b: = get_child(6) as MyButton


func _ready() -> void:
	_btn_left_a.button_down.connect(_on_button_left_a)
	_btn_right_a.button_down.connect(_on_button_right_a)
	_btn_left_b.button_down.connect(_on_button_left_b)
	_btn_right_b.button_down.connect(_on_button_right_b)

	await get_tree().process_frame
	_layout()
	_values()


func _create() -> void:															# check if nodes exist
	if _label == null:															# create if missing
		_label = Label.new()
		add_child(_label)
		_label.owner = self
		_label.name = "Label"

	if _color_a == null:
		_color_a = ColorRect.new()
		add_child(_color_a)
		_color_a.owner = self
		_color_a.name = "ColorA"

	if _btn_left_a == null:
		_btn_left_a = MyButton.new()
		add_child(_btn_left_a)
		_btn_left_a.owner = self
		_btn_left_a.name = "BtnLeftA"

	if _btn_right_a == null:
		_btn_right_a = MyButton.new()
		add_child(_btn_right_a)
		_btn_right_a.owner = self
		_btn_right_a.name = "BtnRightA"

	if _color_b == null:
		_color_b = ColorRect.new()
		add_child(_color_b)
		_color_b.owner = self
		_color_b.name = "ColorB"

	if _btn_left_b == null:
		_btn_left_b = MyButton.new()
		add_child(_btn_left_b)
		_btn_left_b.owner = self
		_btn_left_b.name = "BtnLeftB"

	if _btn_right_b == null:
		_btn_right_b = MyButton.new()
		add_child(_btn_right_b)
		_btn_right_b.owner = self
		_btn_right_b.name = "BtnRightB"

	await get_tree().process_frame
	_layout()
	_values()


func _layout() -> void:															# default values
	_label.set_anchors_and_offsets_preset(Control.PRESET_CENTER_LEFT)
	_label.label_settings = _label_settings
	_label.position.x = -1.0
	_label.text = _title

	_color_a.set_anchors_and_offsets_preset(Control.PRESET_CENTER_RIGHT)
	_color_a.size = Vector2(8.0, 8.0)
	_color_a.position.x -= 46
	_color_a.position.y -= 4
	_color_a.color = _options[_default_a]

	_btn_left_a.set_anchors_and_offsets_preset(Control.PRESET_CENTER_RIGHT)
	_btn_left_a.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_btn_left_a.position.x -= 44
	_btn_left_a.texture_normal = _texture_left

	_btn_right_a.set_anchors_and_offsets_preset(Control.PRESET_CENTER_RIGHT)
	_btn_right_a.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_btn_right_a.position.x -= 24
	_btn_right_a.texture_normal = _texture_right

	_color_b.set_anchors_and_offsets_preset(Control.PRESET_CENTER_RIGHT)
	_color_b.size = Vector2(8.0, 8.0)
	_color_b.position.x -= 17
	_color_b.position.y -= 4
	_color_b.color = _options[_default_b]

	_btn_left_b.set_anchors_and_offsets_preset(Control.PRESET_CENTER_RIGHT)
	_btn_left_b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_btn_left_b.position.x -= 15
	_btn_left_b.texture_normal = _texture_left

	_btn_right_b.set_anchors_and_offsets_preset(Control.PRESET_CENTER_RIGHT)
	_btn_right_b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_btn_right_b.position.x += 5
	_btn_right_b.texture_normal = _texture_right


func _values() -> void:
	if _is_enabled == true:
		enable()
	else:
		disable()

	_option_max = _options.size()
	_option_index_a = _default_a
	_option_index_b = _default_b


func set_color_a(index: int, _has_signal: bool = false) -> void:
	_color_a.color = _options[index]
	_option_index_a = index

	if _has_signal == true:
		value_changed.emit(_options[_option_index_a], _options[_option_index_b], _option_index_a, _option_index_b)


func set_color_b(index: int, _has_signal: bool = false) -> void:
	_color_b.color = _options[index]
	_option_index_b = index

	if _has_signal == true:
		value_changed.emit(_options[_option_index_a], _options[_option_index_b], _option_index_a, _option_index_b)


func enable() -> void:
	_is_enabled = true

	_label.modulate = "ffffff"
	_color_a.modulate = "ffffff"
	_btn_left_a.enable()
	_btn_right_a.enable()
	_color_b.modulate = "ffffff"
	_btn_left_b.enable()
	_btn_right_b.enable()


func disable() -> void:
	_is_enabled = false

	_label.modulate = "ffffff4b"
	_color_a.modulate = "ffffff4b"
	_btn_left_a.disable()
	_btn_right_a.disable()
	_color_b.modulate = "ffffff4b"
	_btn_left_b.disable()
	_btn_right_b.disable()


func _on_button_left_a() -> void:
	_option_index_a = wrapi(_option_index_a - 1, 0, _option_max)

	_color_a.color = _options[_option_index_a]
	value_changed.emit(_options[_option_index_a], _options[_option_index_b], _option_index_a, _option_index_b)


func _on_button_right_a() -> void:
	_option_index_a = wrapi(_option_index_a + 1, 0, _option_max)

	_color_a.color = _options[_option_index_a]
	value_changed.emit(_options[_option_index_a], _options[_option_index_b], _option_index_a, _option_index_b)


func _on_button_left_b() -> void:
	_option_index_b = wrapi(_option_index_b - 1, 0, _option_max)

	_color_b.color = _options[_option_index_b]
	value_changed.emit(_options[_option_index_a], _options[_option_index_b], _option_index_a, _option_index_b)


func _on_button_right_b() -> void:
	_option_index_b = wrapi(_option_index_b + 1, 0, _option_max)

	_color_b.color = _options[_option_index_b]
	value_changed.emit(_options[_option_index_a], _options[_option_index_b], _option_index_a, _option_index_b)
