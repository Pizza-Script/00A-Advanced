@tool
class_name MyCounterFour
extends Control

# .change_value(value)
# .sub_value(type = 0, steps = 1.0)												# 0 = small, 1 = large
# .add_value(type = 0, steps = 1.0)

# .enable()
# .disable()

signal value_changed(value: float)

const MIN: float = -9_223_372_036_854_775_807
const MAX: float = +9_223_372_036_854_775_807

const SMALL: int = 0
const LARGE: int = 1

#region Images
@export_group("Images")
@export var _texture_button: Texture2D = preload("Texture/my_counter_four.png")
#endregion

@export_group("", "")
@export var _is_enabled: bool = true
@export var _key_shortcuts: bool = false
@export var _title: String = "COUNTER"
@export var _min_value: float = -1.0
@export var _max_value: float = -1.0
@export var _default: float = 100
@export var _step_A: float = 10
@export var _step_B: float = 100
@export var _format: String = "%02d"
@export var _label_settings: LabelSettings
@export_tool_button("Create", "FadeDisabled") var create = _create

var _value: float

var _step_type: int
var _held_type: int
var _held_timer: float
var _held_spent: float
var _held_repeat: int

var _min: float
var _max: float

@onready var _lbl_title := get_child(0) as Label
@onready var _lbl_count := get_child(1) as Label

@onready var _btn_sub_B := get_child(2) as MyButton
@onready var _btn_sub_A := get_child(3) as MyButton
@onready var _btn_add_A := get_child(4) as MyButton
@onready var _btn_add_B := get_child(5) as MyButton

@onready var _lbl_sub_B := _btn_sub_B.get_child(0) as Label
@onready var _lbl_sub_A := _btn_sub_A.get_child(0) as Label
@onready var _lbl_add_A := _btn_add_A.get_child(0) as Label
@onready var _lbl_add_B := _btn_add_B.get_child(0) as Label


func _ready() -> void:
	_btn_sub_B.pressed.connect(_sub_pressed.bind(LARGE))
	_btn_sub_B.button_down.connect(_sub_held.bind(LARGE))
	_btn_sub_B.button_up.connect(_released)

	_btn_sub_A.pressed.connect(_sub_pressed.bind(SMALL))
	_btn_sub_A.button_down.connect(_sub_held.bind(SMALL))
	_btn_sub_A.button_up.connect(_released)

	_btn_add_A.pressed.connect(_add_pressed.bind(SMALL))
	_btn_add_A.button_down.connect(_add_held.bind(SMALL))
	_btn_add_A.button_up.connect(_released)

	_btn_add_B.pressed.connect(_add_pressed.bind(LARGE))
	_btn_add_B.button_down.connect(_add_held.bind(LARGE))
	_btn_add_B.button_up.connect(_released)

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

	if _btn_sub_B == null:
		_btn_sub_B = MyButton.new()
		add_child(_btn_sub_B)
		_btn_sub_B.owner = self
		_btn_sub_B.name = "BtnSubB"

	if _lbl_sub_B == null:
		_lbl_sub_B = Label.new()
		add_child(_lbl_sub_B)
		_lbl_sub_B.owner = self
		_lbl_sub_B.name = "LabelSubB"

	if _btn_sub_A == null:
		_btn_sub_A = MyButton.new()
		add_child(_btn_sub_A)
		_btn_sub_A.owner = self
		_btn_sub_A.name = "BtnSubA"

	if _lbl_sub_A == null:
		_lbl_sub_A = Label.new()
		add_child(_lbl_sub_A)
		_lbl_sub_A.owner = self
		_lbl_sub_A.name = "LabelSubA"

	if _btn_add_A == null:
		_btn_add_A = MyButton.new()
		add_child(_btn_add_A)
		_btn_add_A.owner = self
		_btn_add_A.name = "BtnPlusA"

	if _lbl_add_A == null:
		_lbl_add_A = Label.new()
		add_child(_lbl_add_A)
		_lbl_add_A.owner = self
		_lbl_add_A.name = "LabelAddA"

	if _btn_add_B == null:
		_btn_add_B = MyButton.new()
		add_child(_btn_add_B)
		_btn_add_B.owner = self
		_btn_add_B.name = "BtnPlusB"

	if _lbl_add_B == null:
		_lbl_add_B = Label.new()
		add_child(_lbl_add_B)
		_lbl_add_B.owner = self
		_lbl_add_B.name = "LabelAddB"

	await get_tree().process_frame
	_layout()
	_values()


func _layout() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	_lbl_title.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	_lbl_title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_lbl_title.position.y -= 2.0
	_lbl_title.position.x -= 1.0
	_lbl_title.label_settings = _label_settings
	_lbl_title.text = _title

	_lbl_count.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	_lbl_count.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_lbl_count.pivot_offset_ratio.x = 1.0
	_lbl_count.position.x -= 48.0 - _lbl_count.size.x							# target_size - current_size
	_lbl_count.position.y -= 2.0
	_lbl_count.size.x = 48.0
	_lbl_count.label_settings = _label_settings
	_lbl_count.text = _format % _default

	_btn_sub_B.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT)
	_btn_sub_B.texture_normal = _texture_button

	_lbl_sub_B.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_lbl_sub_B.label_settings = _label_settings
	_lbl_sub_B.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_lbl_sub_B.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_lbl_sub_B.position.y -= 1.0

	_btn_sub_A.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT)
	_btn_sub_A.texture_normal = _texture_button

	_lbl_sub_A.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_lbl_sub_A.label_settings = _label_settings
	_lbl_sub_A.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_lbl_sub_A.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_lbl_sub_A.position.y -= 1.0

	_btn_add_A.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
	_btn_add_A.texture_normal = _texture_button

	_lbl_add_A.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_lbl_add_A.label_settings = _label_settings
	_lbl_add_A.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_lbl_add_A.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_lbl_add_A.position.y -= 1.0

	_btn_add_B.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
	_btn_add_B.texture_normal = _texture_button

	_lbl_add_B.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_lbl_add_B.label_settings = _label_settings
	_lbl_add_B.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_lbl_add_B.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_lbl_add_B.position.y -= 1.0

	await get_tree().process_frame
	_btn_sub_A.position.x = _btn_sub_B.size.x + 1.0
	_btn_add_A.position.x -= _btn_add_B.size.x + 1.0


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
			_sub_pressed(_step_type)
		elif _held_type == 1:
			_add_pressed(_step_type)


func enable() -> void:
	_is_enabled = true

	_lbl_title.modulate = "ffffff"
	_lbl_count.modulate = "ffffff"
	_btn_sub_B.enable()
	_btn_sub_A.enable()
	_btn_add_A.enable()
	_btn_add_B.enable()


func disable() -> void:
	_is_enabled = false

	_lbl_title.modulate = "ffffff4b"
	_lbl_count.modulate = "ffffff4b"
	_btn_sub_B.disable()
	_btn_sub_A.disable()
	_btn_add_A.disable()
	_btn_add_B.disable()


func change_value(count: float) -> void:										# no signal
	_value = clampf(count, _min, _max)
	_lbl_count.text = _format % _value


func sub_value(type: int = 0, steps: float = 1.0) -> void:						# no signal
	if type == 0:
		_value = clampf(_value - (_step_A * steps), _min, _max)
	elif type == 1:
		_value = clampf(_value - (_step_B * steps), _min, _max)

	_lbl_count.text = _format % _value


func add_value(type: int = 0, steps: float = 1.0) -> void:						# no signal
	if type == 0:
		_value = clampf(_value + (_step_A * steps), _min, _max)
	elif type == 1:
		_value = clampf(_value + (_step_B * steps), _min, _max)

	_lbl_count.text = _format % _value


func _sub_pressed(step_type: int = SMALL) -> void:
	_step_type = step_type

	if _step_type == SMALL:
		_value = clampf(_value - _step_A, _min, _max)
	elif _step_type == LARGE:
		_value = clampf(_value - _step_B, _min, _max)

	_lbl_count.text = _format % _value
	value_changed.emit(_value)


func _add_pressed(step_type: int = SMALL) -> void:
	_step_type = step_type

	if _step_type == SMALL:
		_value = clampf(_value + _step_A, _min, _max)
	elif _step_type == LARGE:
		_value = clampf(_value + _step_B, _min, _max)

	_lbl_count.text = _format % _value
	value_changed.emit(_value)


func _sub_held(step_type: int = SMALL) -> void:
	_step_type = step_type
	_held_type = 0
	_held_timer = 0.5
	_held_spent = 0.0
	_held_repeat = 0
	set_process(true)


func _add_held(step_type: int = SMALL) -> void:
	_step_type = step_type
	_held_type = 1
	_held_timer = 0.5
	_held_spent = 0.0
	_held_repeat = 0
	set_process(true)


func _released() -> void:
	set_process(false)
