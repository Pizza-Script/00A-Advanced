@tool
class_name MySliderVector
extends Control

# .change_value(value: Vector2)
# .change_value_x(value: float)
# .change_value_y(value: float)

# .enable()
# .disable()

signal value_changed(value: Vector2)

#region Images
@export_group("Images")
@export var _reset_texture: Texture2D = preload("Texture/reset.png")
@export var _slider_image: Texture2D = preload("Texture/grabber.png")
@export var _slider_hover: Texture2D = preload("Texture/grabber_hover.png")
@export var _slider_style: StyleBoxFlat = preload("Style/style.tres")
@export var _slider_style_grabber: StyleBoxFlat = preload("Style/style_grabber.tres")
@export var _slider_style_highlight: StyleBoxFlat = preload("Style/style_grabber_highlight.tres")
#endregion

@export_group("", "")
@export var _is_enabled: bool = true
@export var _is_resetable: bool = true
@export var _is_scrollable: bool = true
@export var _title: String = "VECTOR"
@export var _min_value: float = -100.0
@export var _max_value: float = +100.0
@export var _default_x: float = 0.0
@export var _default_y: float = 0.0
@export var _step: float = 1.0
@export var _format: String = "%5.1f"	# "%03d"
@export var _label_settings: LabelSettings
@export_tool_button("Create", "FadeDisabled") var create = _create

@onready var _lbl_title := get_child(0) as Label
@onready var _lbl_x := get_child(1) as Label
@onready var _lbl_y := get_child(2) as Label
@onready var _btn_reset: = get_child(3) as MyButton
@onready var _slider_x := get_child(4) as HSlider
@onready var _slider_y := get_child(5) as HSlider
@onready var _lbl_value_x := get_child(6) as Label
@onready var _lbl_value_y := get_child(7) as Label


func _ready() -> void:
	_btn_reset.button_up.connect(_on_button_reset)
	_slider_x.value_changed.connect(_on_value_changed_x)
	_slider_y.value_changed.connect(_on_value_changed_y)
	_slider_x.mouse_entered.connect(_on_slider_entered)
	_slider_x.mouse_exited.connect(_on_slider_exited)
	_slider_y.mouse_entered.connect(_on_slider_entered)
	_slider_y.mouse_exited.connect(_on_slider_exited)

	await get_tree().process_frame
	_layout()
	_values()


func _create() -> void:															# check if nodes exist
	if _lbl_title == null:														# create if missing
		_lbl_title = Label.new()
		add_child(_lbl_title)
		_lbl_title.owner = self
		_lbl_title.name = "LblTitle"

	if _lbl_x == null:
		_lbl_x = Label.new()
		add_child(_lbl_x)
		_lbl_x.owner = self
		_lbl_x.name = "LblX"

	if _lbl_y == null:
		_lbl_y = Label.new()
		add_child(_lbl_y)
		_lbl_y.owner = self
		_lbl_y.name = "LblY"

	if _btn_reset == null:
		_btn_reset = MyButton.new()
		add_child(_btn_reset)
		_btn_reset.owner = self
		_btn_reset.name = "BtnReset"

	if _slider_x == null:
		_slider_x = HSlider.new()
		add_child(_slider_x)
		_slider_x.owner = self
		_slider_x.name = "SliderX"

	if _slider_y == null:
		_slider_y = HSlider.new()
		add_child(_slider_y)
		_slider_y.owner = self
		_slider_y.name = "SliderY"

	if _lbl_value_x == null:
		_lbl_value_x = Label.new()
		add_child(_lbl_value_x)
		_lbl_value_x.owner = self
		_lbl_value_x.name = "LblValueX"

	if _lbl_value_y == null:
		_lbl_value_y = Label.new()
		add_child(_lbl_value_y)
		_lbl_value_y.owner = self
		_lbl_value_y.name = "LblValueY"

	await get_tree().process_frame
	_layout()
	_values()


func _layout() -> void:															# default values
	_lbl_title.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	_lbl_title.label_settings = _label_settings
	_lbl_title.position = Vector2(-1.0, -2.0)
	_lbl_title.text = _title

	_lbl_x.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	_lbl_x.label_settings = _label_settings
	_lbl_x.position = Vector2(-1.0, 10.0)
	_lbl_x.text = "X"

	_lbl_y.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	_lbl_y.label_settings = _label_settings
	_lbl_y.position = Vector2(-1.0, 24.0)
	_lbl_y.text = "Y"

	_btn_reset.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	_btn_reset.position.x += 3.0
	_btn_reset.position.y = -5.0
	_btn_reset.texture_normal = _reset_texture

	_slider_x.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	_slider_x.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_slider_x.size.x -= 12.0
	_slider_x.size.y -= 8.0
	_slider_x.position = Vector2(10.0, 10.0)
	_slider_x.add_theme_icon_override("grabber", _slider_image)
	_slider_x.add_theme_icon_override("grabber_highlight", _slider_hover)
	_slider_x.add_theme_icon_override("grabber_disabled", _slider_image)
	_slider_x.add_theme_stylebox_override("slider", _slider_style)
	_slider_x.add_theme_stylebox_override("grabber_area", _slider_style_grabber)
	_slider_x.add_theme_stylebox_override("grabber_area_highlight", _slider_style_highlight)
	_slider_x.min_value = _min_value
	_slider_x.max_value = _max_value
	_slider_x.value = _default_x
	_slider_x.step = _step

	_slider_y.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	_slider_y.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_slider_y.size.x -= 12.0
	_slider_y.size.y -= 8.0
	_slider_y.position = Vector2(10.0, 24.0)
	_slider_y.add_theme_icon_override("grabber", _slider_image)
	_slider_y.add_theme_icon_override("grabber_highlight", _slider_hover)
	_slider_y.add_theme_icon_override("grabber_disabled", _slider_image)
	_slider_y.add_theme_stylebox_override("slider", _slider_style)
	_slider_y.add_theme_stylebox_override("grabber_area", _slider_style_grabber)
	_slider_y.add_theme_stylebox_override("grabber_area_highlight", _slider_style_highlight)
	_slider_y.min_value = _min_value
	_slider_y.max_value = _max_value
	_slider_y.value = _default_y
	_slider_y.step = _step

	# _slider_x.focus_mode = Control.FOCUS_NONE									# avoid focus highlight (& keyboard control)
	# _slider_y.focus_mode = Control.FOCUS_NONE									# avoid focus highlight (& keyboard control)

	_lbl_value_x.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	_lbl_value_x.label_settings = _label_settings
	_lbl_value_x.position.x -= 3.0
	_lbl_value_x.position.y += 10.0
	_lbl_value_x.text = _format % _default_x

	_lbl_value_y.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	_lbl_value_y.label_settings = _label_settings
	_lbl_value_y.position.x -= 3.0
	_lbl_value_y.position.y += 24.0
	_lbl_value_y.text = _format % _default_y


func _values() -> void:
	if _is_enabled == true:
		enable()
	else:
		disable()

	if _is_resetable == true:
		_btn_reset.visible = true
	elif _is_resetable == false:
		_btn_reset.visible = false

	change_value(Vector2(_default_x, _default_y))


func _unhandled_key_input(event: InputEvent) -> void:
	var key_event: = event as InputEventKey
	var key: Key = key_event.keycode

	if key_event.pressed == false:
		return

	if _slider_x.has_focus() == true:

		if key == KEY_LEFT || key == KEY_DOWN:
			var value: Vector2 = Vector2(_slider_x.value, _slider_y.value)
			value.x = clampf(value.x - _step, _min_value, _max_value)
			_lbl_value_x.text = _format % value.x
			_slider_x.set_value_no_signal(value.x)
			value_changed.emit(value)

		elif key == KEY_RIGHT || key == KEY_UP:
			var value: Vector2 = Vector2(_slider_x.value, _slider_y.value)
			value.x = clampf(value.x + _step, _min_value, _max_value)
			_lbl_value_x.text = _format % value.x
			_slider_x.set_value_no_signal(value.x)
			value_changed.emit(value)

	elif _slider_y.has_focus() == true:

		if key == KEY_LEFT || key == KEY_DOWN:
			var value: Vector2 = Vector2(_slider_x.value, _slider_y.value)
			value.y = clampf(value.y - _step, _min_value, _max_value)
			_lbl_value_y.text = _format % value.y
			_slider_y.set_value_no_signal(value.y)
			value_changed.emit(value)

		elif key == KEY_RIGHT || key == KEY_UP:
			var value: Vector2 = Vector2(_slider_x.value, _slider_y.value)
			value.y = clampf(value.y + _step, _min_value, _max_value)
			_lbl_value_y.text = _format % value.y
			_slider_y.set_value_no_signal(value.y)
			value_changed.emit(value)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and (event as InputEventMouseButton).pressed:
		var mouse_event: InputEventMouseButton = event as InputEventMouseButton

		if _is_scrollable == false:
			return

		if _slider_x.has_focus() == true:

			if mouse_event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				var value: Vector2 = Vector2(_slider_x.value, _slider_y.value)
				value.x = clampf(value.x - _step, _min_value, _max_value)
				_lbl_value_x.text = _format % value.x
				_slider_x.set_value_no_signal(value.x)
				value_changed.emit(value)

			elif mouse_event.button_index == MOUSE_BUTTON_WHEEL_UP:
				var value: Vector2 = Vector2(_slider_x.value, _slider_y.value)
				value.x = clampf(value.x + _step, _min_value, _max_value)
				_lbl_value_x.text = _format % value.x
				_slider_x.set_value_no_signal(value.x)
				value_changed.emit(value)

		elif _slider_y.has_focus() == true:

			if mouse_event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				var value: Vector2 = Vector2(_slider_x.value, _slider_y.value)
				value.y = clampf(value.y - _step, _min_value, _max_value)
				_lbl_value_y.text = _format % value.y
				_slider_y.set_value_no_signal(value.y)
				value_changed.emit(value)

			elif mouse_event.button_index == MOUSE_BUTTON_WHEEL_UP:
				var value: Vector2 = Vector2(_slider_x.value, _slider_y.value)
				value.y = clampf(value.y + _step, _min_value, _max_value)
				_lbl_value_y.text = _format % value.y
				_slider_y.set_value_no_signal(value.y)
				value_changed.emit(value)


func change_value(value: Vector2) -> void:
	_slider_x.set_value_no_signal(value.x)
	_slider_y.set_value_no_signal(value.y)
	_lbl_value_x.text = _format % value.x
	_lbl_value_y.text = _format % value.y

	if value.x == _default_x && value.y == _default_y:
		_btn_reset.disable()
	else:
		_btn_reset.enable()


func change_value_x(value: float) -> void:
	_slider_x.set_value_no_signal(value)
	_lbl_value_x.text = _format % value

	if value == _default_x && _slider_y.value == _default_y:
		_btn_reset.disable()
	else:
		_btn_reset.enable()


func change_value_y(value: float) -> void:
	_slider_y.set_value_no_signal(value)
	_lbl_value_y.text = _format % value

	if _slider_x.value == _default_x && value == _default_y:
		_btn_reset.disable()
	else:
		_btn_reset.enable()


func my_randomize(_has_signal: bool = true) -> void:
	var value_x: float = MyRand.f_range(_min_value, _max_value)
	var value_y: float = MyRand.f_range(_min_value, _max_value)

	change_value_x(value_x)
	change_value_y(value_y)

	if _has_signal == true:
		value_changed.emit(Vector2(value_x, value_y))


func enable() -> void:
	_is_enabled = true

	_lbl_title.modulate = "ffffff"
	_lbl_x.modulate = "ffffff"
	_lbl_y.modulate = "ffffff"
	_lbl_value_x.modulate = "ffffff"
	_lbl_value_y.modulate = "ffffff"
	_slider_x.modulate = "ffffffaf"
	_slider_x.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_slider_x.editable = true
	_slider_y.modulate = "ffffffaf"
	_slider_y.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_slider_y.editable = true

	if _slider_x.value == _default_x && _slider_y.value == _default_y:
		_btn_reset.disable()
	else:
		_btn_reset.enable()


func disable() -> void:
	_is_enabled = false

	_lbl_title.modulate = "ffffff4b"
	_lbl_x.modulate = "ffffff4b"
	_lbl_y.modulate = "ffffff4b"
	_lbl_value_x.modulate = "ffffff4b"
	_lbl_value_y.modulate = "ffffff4b"
	_slider_x.modulate = "ffffff4b"
	_slider_x.mouse_default_cursor_shape = Control.CURSOR_FORBIDDEN
	_slider_x.editable = false
	_slider_y.modulate = "ffffff4b"
	_slider_y.mouse_default_cursor_shape = Control.CURSOR_FORBIDDEN
	_slider_y.editable = false
	_btn_reset.disable()


func _on_value_changed_x(value: float) -> void:
	change_value(Vector2(value, _slider_y.value))
	value_changed.emit(Vector2(value, _slider_y.value))


func _on_value_changed_y(value: float) -> void:
	change_value(Vector2(_slider_x.value, value))
	value_changed.emit(Vector2(_slider_x.value, value))


func _on_button_reset() -> void:
	change_value(Vector2(_default_x, _default_y))
	value_changed.emit(Vector2(_default_x, _default_y))


func _on_slider_entered() -> void:
	if _is_enabled == false:
		return

	_slider_x.modulate = "ffffff"
	_slider_y.modulate = "ffffff"


func _on_slider_exited() -> void:
	if _is_enabled == false:
		return

	_slider_x.modulate = "ffffffaf"
	_slider_y.modulate = "ffffffaf"
