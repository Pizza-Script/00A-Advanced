@tool
class_name MySlider
extends Control

# .change_value(value: float)

# .enable()
# .disable()

signal value_changed(value: float)

#region Images
@export_group("Images")
@export var _texture_reset: Texture2D = preload("Texture/reset.png")
@export var _slider_image: Texture2D = preload("Texture/grabber_W.png")
@export var _slider_hover: Texture2D = preload("Texture/grabber_W_hover.png")
@export var _slider_style: StyleBoxFlat = preload("Style/style.tres")
@export var _slider_style_grabber: StyleBoxFlat = preload("Style/style_grabber.tres")
@export var _slider_style_highlight: StyleBoxFlat = preload("Style/style_grabber_highlight.tres")
#endregion

@export_group("", "")
@export var _is_enabled: bool = true
@export var _is_resetable: bool = true
@export var _is_scrollable: bool = true
@export var _title: String = "SLIDER"
@export var _min_value: float = -100.0
@export var _max_value: float = +100.0
@export var _default: float = 0.0
@export var _step: float = 1.0
@export var _format: String = "%5.1f"	# "%03d"
@export var _label_settings: LabelSettings
@export_tool_button("Create", "FadeDisabled") var create = _create

@onready var _lbl_title := get_child(0) as Label
@onready var _lbl_value := get_child(1) as Label
@onready var _slider := get_child(2) as HSlider
@onready var _btn_reset: = get_child(3) as MyButton


func _ready() -> void:
	_btn_reset.button_up.connect(_on_button_reset)
	_slider.value_changed.connect(_on_value_changed)
	_slider.mouse_entered.connect(_on_slider_entered)
	_slider.mouse_exited.connect(_on_slider_exited)

	await get_tree().process_frame
	_layout()
	_values()


func _create() -> void:															# check if nodes exist
	if _lbl_title == null:														# create if missing
		_lbl_title = Label.new()
		add_child(_lbl_title)
		_lbl_title.owner = self
		_lbl_title.name = "LblTitle"

	if _lbl_value == null:
		_lbl_value = Label.new()
		add_child(_lbl_value)
		_lbl_value.owner = self
		_lbl_value.name = "LblValue"

	if _slider == null:
		_slider = HSlider.new()
		add_child(_slider)
		_slider.owner = self
		_slider.name = "HSlider"

	if _btn_reset == null:
		_btn_reset = MyButton.new()
		add_child(_btn_reset)
		_btn_reset.owner = self
		_btn_reset.name = "BtnReset"

	await get_tree().process_frame
	_layout()
	_values()


func _layout() -> void:															# default values
	_lbl_title.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	_lbl_title.label_settings = _label_settings
	_lbl_title.position = Vector2(-1.0, -2.0)
	_lbl_title.text = _title

	_lbl_value.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	_lbl_value.label_settings = _label_settings
	_lbl_value.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_lbl_value.position.y = -2.0
	_lbl_value.text = _format % _default

	_slider.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	_slider.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_slider.size.x -= 4.0
	_slider.size.y -= 8.0
	_slider.position = Vector2(2.0, 10.0)
	_slider.add_theme_icon_override("grabber", _slider_image)
	_slider.add_theme_icon_override("grabber_highlight", _slider_hover)
	_slider.add_theme_icon_override("grabber_disabled", _slider_image)
	_slider.add_theme_stylebox_override("slider", _slider_style)
	_slider.add_theme_stylebox_override("grabber_area", _slider_style_grabber)
	_slider.add_theme_stylebox_override("grabber_area_highlight", _slider_style_highlight)
	_slider.min_value = _min_value
	_slider.max_value = _max_value
	_slider.value = _default
	_slider.step = _step

	# _slider.focus_mode = Control.FOCUS_NONE									# avoid focus highlight (& keyboard control)
	# changing min_value triggers "value_changed" signal

	_btn_reset.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	_btn_reset.position.y = -5.0
	_btn_reset.texture_normal = _texture_reset


func _values() -> void:
	if _is_enabled == true:
		enable()
	else:
		disable()

	if _is_resetable == true:
		_lbl_value.position.x -= 12.0
		_btn_reset.position.x += 3.0
		_btn_reset.visible = true

	elif _is_resetable == false:
		_btn_reset.visible = false

	change_value(_default)


func _unhandled_key_input(event: InputEvent) -> void:
	var key_event: = event as InputEventKey
	var key: Key = key_event.keycode

	if key_event.pressed == false:
		return

	if _slider.has_focus() == false:
		return

	if key == KEY_LEFT || key == KEY_DOWN:
		var value: float = _slider.value
		value = clampf(value - _step, _min_value, _max_value)
		_lbl_value.text = _format % value
		_slider.set_value_no_signal(value)
		value_changed.emit(value)

	elif key == KEY_RIGHT || key == KEY_UP:
		var value: float = _slider.value
		value = clampf(value + _step, _min_value, _max_value)
		_lbl_value.text = _format % value
		_slider.set_value_no_signal(value)
		value_changed.emit(value)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and (event as InputEventMouseButton).pressed:
		var mouse_event: InputEventMouseButton = event as InputEventMouseButton

		if _is_scrollable == false:
			return

		if _slider.has_focus() == false:
			return

		if mouse_event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			var value: float = _slider.value
			value = clampf(value - _step, _min_value, _max_value)
			_lbl_value.text = _format % value
			_slider.set_value_no_signal(value)
			value_changed.emit(value)

		elif mouse_event.button_index == MOUSE_BUTTON_WHEEL_UP:
			var value: float = _slider.value
			value = clampf(value + _step, _min_value, _max_value)
			_lbl_value.text = _format % value
			_slider.set_value_no_signal(value)
			value_changed.emit(value)


func change_value(value: float) -> void:
	_lbl_value.text = _format % value
	_slider.set_value_no_signal(value)

	if value == _default:
		_btn_reset.disable()
	elif value != _default:
		_btn_reset.enable()


func my_randomize(_has_signal: bool = true) -> void:
	var rand_value: float = MyRand.f_range(_min_value, _max_value)
	change_value(rand_value)

	if _has_signal == true:
		value_changed.emit(rand_value)


func enable() -> void:
	_is_enabled = true

	_lbl_title.modulate = "ffffff"
	_lbl_value.modulate = "ffffff"
	_slider.modulate = "ffffffaf"
	_slider.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_slider.editable = true

	if _slider.value == _default:
		_btn_reset.disable()
	else:
		_btn_reset.enable()


func disable() -> void:
	_is_enabled = false

	_lbl_title.modulate = "ffffff4b"
	_lbl_value.modulate = "ffffff4b"
	_slider.modulate = "ffffff4b"
	_slider.mouse_default_cursor_shape = Control.CURSOR_FORBIDDEN
	_slider.editable = false
	_btn_reset.disable()


func _on_value_changed(value: float) -> void:
	change_value(value)
	value_changed.emit(value)


func _on_button_reset() -> void:
	change_value(_default)
	value_changed.emit(_default)


func _on_slider_entered() -> void:
	if _is_enabled == false:
		return

	_slider.modulate = "ffffff"


func _on_slider_exited() -> void:
	if _is_enabled == false:
		return

	_slider.modulate = "ffffffaf"
