@tool
class_name MySliderMinMax
extends Control

# .set_anchors_and_offsets_preset() is needed
# .set_anchors_preset() sometimes incorrect size

# .change_min(value: float)														# _has_signal = false
# .change_max(value: float)
# .my_randomize()

# .enable()
# .disable()

# perfect is the enemy of good
# TODO: scroll input
# TODO: clicking on bar

signal value_changed(min_value: float, max_value: float)

#region Images
@export_group("Images")
@export var _texture_reset: Texture2D = preload("Texture/reset.png")
@export var _slider_bar: Texture2D = preload("Texture/slider_bar.png")
@export var _slider_box: Texture2D = preload("Texture/slider_box.png")
@export var _slider_max: Texture2D = preload("Texture/slider_max.png")
@export var _slider_min: Texture2D = preload("Texture/slider_min.png")
#endregion

@export_group("", "")
@export var _is_enabled: bool = true
@export var _is_resetable: bool = true
@export var _title: String = "MIN MAX"
@export var _min_limit: float = -100.0
@export var _max_limit: float = +100.0
@export var _default_min: float = 0.0
@export var _default_max: float = 0.0
@export var _step: float = 1.0
@export var _format: String = "%3.1f"	# "%03d"
@export var _color_min: Color = Color("41a6f6")
@export var _color_max: Color = Color("a7f070")
@export var _label_settings: LabelSettings
@export_tool_button("Create", "FadeDisabled") var create = _create

var _is_min_hover: bool
var _is_max_hover: bool
var _is_min_held: bool
var _is_max_held: bool

var min_value: float
var max_value: float

var _value_total: float
var _value_ratio: float

var _position_min: float
var _position_max: float
var _position_mid: float
var _position_total: float

var _mouse_position_x: float

#region nodes
@onready var _labels: = get_child(0) as Control
@onready var _slider: = get_child(1) as Control
@onready var _output: = get_child(2) as Control

@onready var _lbl_title: = _labels.get_child(0) as Label
@onready var _btn_reset: = _labels.get_child(1) as MyButton

@onready var _bar: = _slider.get_child(0) as Control
@onready var _img_bar: = _bar.get_child(0) as TextureRect
@onready var _img_min: = _slider.get_child(1) as TextureRect
@onready var _img_max: = _slider.get_child(2) as TextureRect
@onready var _img_box: = _slider.get_child(3) as NinePatchRect

@onready var _lbl_min: = _output.get_child(0) as Label
@onready var _lbl_max: = _output.get_child(1) as Label
#endregion


func _ready() -> void:
	_btn_reset.pressed.connect(_on_button_reset_pressed)
	_img_min.mouse_entered.connect(_on_min_mouse_entered)
	_img_min.mouse_exited.connect(_on_min_mouse_exited)
	_img_max.mouse_entered.connect(_on_max_mouse_entered)
	_img_max.mouse_exited.connect(_on_max_mouse_exited)
	_slider.mouse_entered.connect(_on_slider_entered)
	_slider.mouse_exited.connect(_on_slider_exited)

	await get_tree().process_frame
	_layout()
	_values()


func _create() -> void:															# check if nodes exist
	if _labels == null:															# create if missing
		_labels = Control.new()
		add_child(_labels)
		_labels.owner = self
		_labels.name = "Labels"

	if _slider == null:
		_slider = Control.new()
		add_child(_slider)
		_slider.owner = self
		_slider.name = "Slider"

	if _output == null:
		_output = Control.new()
		add_child(_output)
		_output.owner = self
		_output.name = "Values"

	if _lbl_title == null:
		_lbl_title = Label.new()
		_labels.add_child(_lbl_title)
		_lbl_title.owner = self
		_lbl_title.name = "LblTitle"

	if _btn_reset == null:
		_btn_reset = MyButton.new()
		_labels.add_child(_btn_reset)
		_btn_reset.owner = self
		_btn_reset.name = "BtnReset"

	if _bar == null:
		_bar = TextureRect.new()
		_slider.add_child(_bar)
		_bar.owner = self
		_bar.name = "Bar"

	if _img_bar == null:
		_img_bar = TextureRect.new()
		_bar.add_child(_img_bar)
		_img_bar.owner = self
		_img_bar.name = "ImgBar"

	if _img_min == null:
		_img_min = TextureRect.new()
		_slider.add_child(_img_min)
		_img_min.owner = self
		_img_min.name = "ImgMin"

	if _img_max == null:
		_img_max = TextureRect.new()
		_slider.add_child(_img_max)
		_img_max.owner = self
		_img_max.name = "ImgMax"

	if _img_box == null:
		_img_box = NinePatchRect.new()
		_slider.add_child(_img_box)
		_img_box.owner = self
		_img_box.name = "ImgBox"

	if _lbl_min == null:
		_lbl_min = Label.new()
		_output.add_child(_lbl_min)
		_lbl_min.owner = self
		_lbl_min.name = "LblMin"

	if _lbl_max == null:
		_lbl_max = Label.new()
		_output.add_child(_lbl_max)
		_lbl_max.owner = self
		_lbl_max.name = "LblMax"

	await get_tree().process_frame
	_layout()
	_values()


func _layout() -> void:															# default values
	_position_min = 5.0
	_position_max = _img_box.size.x - 7.0
	_position_mid = _position_max * 0.5
	_position_total = _position_max - _position_min

	mouse_filter = Control.MOUSE_FILTER_IGNORE

	_labels.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	_labels.mouse_filter = Control.MOUSE_FILTER_IGNORE

	_slider.set_anchors_and_offsets_preset(Control.PRESET_HCENTER_WIDE)
	_slider.mouse_filter = Control.MOUSE_FILTER_PASS

	_output.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	_output.mouse_filter = Control.MOUSE_FILTER_IGNORE

	_lbl_title.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	_lbl_title.label_settings = _label_settings
	_lbl_title.position = Vector2(-1.0, -2.0)
	_lbl_title.size.y = 8.0
	_lbl_title.text = _title

	_btn_reset.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	_btn_reset.position.x += 3.0
	_btn_reset.position.y = -5.0
	_btn_reset.texture_normal = _texture_reset

	_bar.set_anchors_and_offsets_preset(Control.PRESET_HCENTER_WIDE)
	_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_bar.position.x = _position_mid
	_bar.position.y = -4.0
	_bar.size.x = 0.0
	_bar.size.y = 8.0

	_img_bar.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_img_bar.texture = _slider_bar
	_img_bar.size = _bar.size

	_img_min.set_anchors_and_offsets_preset(Control.PRESET_CENTER_LEFT)
	_img_min.position.x = _position_mid - 3.0
	_img_min.position.y = -4.0
	_img_min.texture = _slider_min
	_img_min.self_modulate = _color_min

	_img_max.set_anchors_and_offsets_preset(Control.PRESET_CENTER_LEFT)
	_img_max.position.x = _position_mid
	_img_max.position.y = -4.0
	_img_max.texture = _slider_max
	_img_max.self_modulate = _color_max

	_img_box.set_anchors_and_offsets_preset(Control.PRESET_HCENTER_WIDE)
	_img_box.position.y = -6.0
	_img_box.texture = _slider_box
	_img_box.patch_margin_top = 1
	_img_box.patch_margin_right = 1
	_img_box.patch_margin_bottom = 1
	_img_box.patch_margin_left = 1
	_img_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_img_box.size.y = 12.0

	_lbl_min.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT)
	_lbl_min.label_settings = _label_settings
	_lbl_min.position = Vector2(-1.0, -7.0)
	_lbl_min.self_modulate = _color_min
	_lbl_min.size.y = 8.0
	_lbl_min.text = _format % _default_min

	_lbl_max.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
	_lbl_max.label_settings = _label_settings
	_lbl_max.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_lbl_max.position.y = -7.0
	_lbl_max.self_modulate = _color_max
	_lbl_max.size.y = 8.0
	_lbl_max.text = _format % _default_max


func _values() -> void:
	if _is_enabled == true:
		enable()
	else:
		disable()

	if _is_resetable == true:
		_btn_reset.visible = true
	elif _is_resetable == false:
		_btn_reset.visible = false

	_value_total = _max_limit - _min_limit

	await get_tree().process_frame
	change_min(_default_min)
	change_max(_default_max)


func _unhandled_input(event: InputEvent) -> void:
	if _is_enabled == false:
		return

	if event is InputEventMouseButton:
		var mouse_event: = event as InputEventMouseButton

		if mouse_event.button_index == MOUSE_BUTTON_LEFT:
			if mouse_event.pressed == true:
				if _is_min_hover == true:
					_is_min_held = true
				elif _is_max_hover == true:
					_is_max_held = true

			elif mouse_event.pressed == false:
				_is_min_held = false
				_is_max_held = false

	elif event is InputEventMouseMotion:
		if _is_min_held == true:
			_adjust_min(get_local_mouse_position().x, true)

		elif _is_max_held == true:
			_adjust_max(get_local_mouse_position().x, true)


func change_min(value: float, _has_signal: bool = false) -> void:
	value = snappedf(value, _step)
	_value_ratio = (value - _min_limit) / _value_total
	_mouse_position_x = (_position_total * _value_ratio) + _position_min
	_adjust_min(_mouse_position_x, _has_signal)


func change_max(value: float, _has_signal: bool = false) -> void:
	value = snappedf(value, _step)
	_value_ratio = (value - _min_limit) / _value_total
	_mouse_position_x = (_position_total * _value_ratio) + _position_min
	_adjust_max(_mouse_position_x, _has_signal)


func my_randomize(_has_signal: bool = true) -> void:
	var rand_min: float = MyRand.f_range(_min_limit, _max_limit)
	var rand_max: float = MyRand.f_range(rand_min, _max_limit)

	change_min(rand_min, _has_signal)
	change_max(rand_max, _has_signal)


func enable() -> void:
	_is_enabled = true

	_lbl_title.modulate = "ffffff"
	_lbl_min.modulate = "ffffff"
	_lbl_max.modulate = "ffffff"
	_img_bar.modulate = "ffffff"
	_img_min.modulate = "ffffff"
	_img_max.modulate = "ffffff"
	_img_box.modulate = "ffffff"
	_slider.modulate = "ffffffaf"
	_img_min.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_img_max.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_btn_reset.enable()


func disable() -> void:
	_is_enabled = false

	_lbl_title.modulate = "ffffff80"
	_lbl_min.modulate = "ffffff80"
	_lbl_max.modulate = "ffffff80"
	_img_bar.modulate = "ffffff80"
	_img_min.modulate = "ffffff80"
	_img_max.modulate = "ffffff80"
	_img_box.modulate = "ffffff80"
	_img_min.mouse_default_cursor_shape = Control.CURSOR_FORBIDDEN
	_img_max.mouse_default_cursor_shape = Control.CURSOR_FORBIDDEN
	_btn_reset.disable()


func _adjust_min(pos_x: float, _has_signal: bool) -> void:
	_mouse_position_x = pos_x
	_mouse_position_x = clampf(_mouse_position_x, _position_min, _position_max)

	_img_min.position.x = _mouse_position_x - 3.0								# position is at top-right
	_bar.position.x = _mouse_position_x
	_bar.size.x = _img_max.position.x - _img_min.position.x - 0.5

	_value_ratio = (_mouse_position_x - _position_min) / _position_total
	min_value = (_value_total * _value_ratio) + _min_limit
	min_value = snappedf(min_value, _step)

	_lbl_min.text = _format % min_value

	if min_value > max_value:
		change_max(min_value)

	if min_value == _default_min && max_value == _default_max:
		_btn_reset.disable()
	else:
		_btn_reset.enable()

	if _has_signal == true:
		value_changed.emit(min_value, max_value)


func _adjust_max(pos_x: float, _has_signal: bool) -> void:
	_mouse_position_x = pos_x
	_mouse_position_x = clampf(_mouse_position_x, _position_min, _position_max)

	_img_max.position.x = _mouse_position_x - 1.0
	_bar.position.x = _img_min.position.x + 4.0
	_bar.size.x = _img_max.position.x - _img_min.position.x - 1.5

	_value_ratio = (_mouse_position_x - _position_min) / _position_total
	max_value = (_value_total * _value_ratio) + _min_limit
	max_value = snappedf(max_value, _step)

	_lbl_max.text = _format % max_value

	if max_value < min_value:
		change_min(max_value)

	if min_value == _default_min && max_value == _default_max:
		_btn_reset.disable()
	else:
		_btn_reset.enable()

	if _has_signal == true:
		value_changed.emit(min_value, max_value)


func _on_min_mouse_entered() -> void:
	if _is_enabled == false:
		return

	_is_min_hover = true
	_img_min.modulate = "e4e4e4"


func _on_min_mouse_exited() -> void:
	if _is_enabled == false:
		return

	_is_min_hover = false
	_img_min.modulate = "ffffff"


func _on_max_mouse_entered() -> void:
	if _is_enabled == false:
		return

	_is_max_hover = true
	_img_max.modulate = "e4e4e4"


func _on_max_mouse_exited() -> void:
	if _is_enabled == false:
		return

	_is_max_hover = false
	_img_max.modulate = "ffffff"


func _on_button_reset_pressed() -> void:
	if _is_enabled == false:
		return

	change_min(_default_min, true)
	change_max(_default_max, true)


func _on_slider_entered() -> void:
	if _is_enabled == false:
		return

	_slider.modulate = "ffffff"


func _on_slider_exited() -> void:
	if _is_enabled == false:
		return

	_slider.modulate = "ffffffaf"
