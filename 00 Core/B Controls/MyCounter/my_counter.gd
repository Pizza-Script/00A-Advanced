@tool
class_name MyCounter
extends Control

# .change_value(value)
# .sub_value(steps = 1.0)
# .add_value(steps = 1.0)

# .enable()
# .disable()

signal value_changed(value: float)

const MIN: float = -9_223_372_036_854_775_807
const MAX: float = +9_223_372_036_854_775_807

#region Images
@export_group("Images")
@export var _texture_sub: Texture2D = preload("Texture/arrow_L.png")
@export var _texture_add: Texture2D = preload("Texture/arrow_R.png")
#endregion

@export_group("", "")
@export var _is_enabled: bool = true
@export var _key_shortcuts: bool = false
@export var _title: String = "COUNTER"
@export var _min_value: float = -1.0
@export var _max_value: float = -1.0
@export var _default: float = 100
@export var _step: float = 1
@export var _format: String = "%02d"
@export var _label_settings: LabelSettings
@export_tool_button("Create", "FadeDisabled") var create = _create

var _value: float

var _held_type: int
var _held_timer: float
var _held_spent: float
var _held_repeat: int

var _min: float
var _max: float

@onready var _lbl_title := get_child(0) as Label
@onready var _lbl_count := get_child(1) as Label
@onready var _btn_sub := get_child(2) as MyButton
@onready var _btn_add := get_child(3) as MyButton


func _ready() -> void:
	_btn_sub.pressed.connect(_sub_pressed)
	_btn_sub.button_down.connect(_sub_held)
	_btn_sub.button_up.connect(_released)

	_btn_add.pressed.connect(_add_pressed)
	_btn_add.button_down.connect(_add_held)
	_btn_add.button_up.connect(_released)

	await get_tree().process_frame
	_layout()
	_values()


func _create() -> void:															# check if nodes exist
	if _lbl_title == null:														# create if missing
		_lbl_title = Label.new()
		add_child(_lbl_title)
		_lbl_title.owner = self
		_lbl_title.name = "LblTitle"

	if _lbl_count == null:
		_lbl_count = Label.new()
		add_child(_lbl_count)
		_lbl_count.owner = self
		_lbl_count.name = "LblCount"

	if _btn_sub == null:
		_btn_sub = MyButton.new()
		add_child(_btn_sub)
		_btn_sub.owner = self
		_btn_sub.name = "BtnSub"

	if _btn_add == null:
		_btn_add = MyButton.new()
		add_child(_btn_add)
		_btn_add.owner = self
		_btn_add.name = "BtnPlus"

	await get_tree().process_frame
	_layout()
	_values()


func _layout() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	_lbl_title.set_anchors_and_offsets_preset(Control.PRESET_CENTER_LEFT)
	_lbl_title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_lbl_title.position.y -= 1.0
	_lbl_title.label_settings = _label_settings
	_lbl_title.text = _title

	_lbl_count.set_anchors_and_offsets_preset(Control.PRESET_CENTER_RIGHT)
	_lbl_count.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_lbl_count.pivot_offset_ratio = Vector2(1.0, 0.5)
	_lbl_count.position.x -= 48.0 - _lbl_count.size.x							# target_size - current_size
	_lbl_count.position.y -= 1.0
	_lbl_count.size.x = 48.0
	_lbl_count.label_settings = _label_settings
	_lbl_count.text = _format % _default

	_btn_sub.set_anchors_and_offsets_preset(Control.PRESET_CENTER_RIGHT)
	_btn_sub.texture_normal = _texture_sub
	_btn_sub.position.x -= 40.0

	_btn_add.set_anchors_and_offsets_preset(Control.PRESET_CENTER_RIGHT)
	_btn_add.texture_normal = _texture_add


func _values() -> void:
	if _is_enabled == true:
		enable()
	elif _is_enabled == false:
		disable()

	if is_equal_approx(_min_value, -1.0) == true:								# NOTE: avoid overwritting export
		_min = MIN
	else:
		_min = _min_value

	if is_equal_approx(_max_value, -1.0) == true:
		_max = MAX
	else:
		_max = _max_value

	_value = _default
	set_process(false)


func _unhandled_key_input(event: InputEvent) -> void:
	if _key_shortcuts == false:
		return

	var key_event: = event as InputEventKey
	var key: Key = key_event.keycode

	if key_event.echo == true:
		return

	if key_event.pressed == true:												# called continuously

		if key == KEY_MINUS or key == KEY_KP_SUBTRACT:
			_sub_pressed()
			_sub_held()

		elif key == KEY_PLUS || key == KEY_KP_ADD || key == KEY_EQUAL:
			_add_pressed()
			_add_held()

	elif key_event.pressed == false:											# called once
		_released()


func _process(delta: float) -> void:
	_held_spent += delta
	if _held_spent >= _held_timer:
		_held_spent = 0.0

		_held_repeat += 1
		if is_equal_approx(_held_timer, 0.5):									# on held
			_held_timer = 0.25													# smaller delay
		elif _held_repeat == 5:
			_held_timer = 0.10													# even smaller delay
		elif _held_repeat == 25:
			_held_timer = 0.02
		elif _held_repeat == 50:
			_held_timer = 0.01

		if _held_type == 0:
			_sub_pressed()
		elif _held_type == 1:
			_add_pressed()


func enable() -> void:
	_is_enabled = true

	_lbl_title.modulate = "ffffff"
	_lbl_count.modulate = "ffffff"
	_btn_sub.enable()
	_btn_add.enable()


func disable() -> void:
	_is_enabled = false

	_lbl_title.modulate = "ffffff4b"
	_lbl_count.modulate = "ffffff4b"
	_btn_sub.disable()
	_btn_add.disable()


func change_value(count: float) -> void:										# no signal
	_value = clampf(count, _min, _max)
	_lbl_count.text = _format % _value


func sub_value(steps: float = 1.0) -> void:										# no signal
	_value = clampf(_value - (_step * steps), _min, _max)
	_lbl_count.text = _format % _value


func add_value(steps: float = 1.0) -> void:										# no signal
	_value = clampf(_value + (_step * steps), _min, _max)
	_lbl_count.text = _format % _value


func _sub_pressed() -> void:
	_value = clampf(_value - _step, _min, _max)
	_lbl_count.text = _format % _value
	value_changed.emit(_value)


func _add_pressed() -> void:
	_value = clampf(_value + _step, _min, _max)
	_lbl_count.text = _format % _value
	value_changed.emit(_value)


func _sub_held() -> void:
	_held_type = 0
	_held_timer = 0.5
	_held_spent = 0.0
	_held_repeat = 0
	set_process(true)


func _add_held() -> void:
	_held_type = 1
	_held_timer = 0.5
	_held_spent = 0.0
	_held_repeat = 0
	set_process(true)


func _released() -> void:
	set_process(false)
