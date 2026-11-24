class_name MenuButtons
extends Control

# @export var _menu: MenuButtons

# func start() -> void:		# new game
# func sleep() -> void:		# pause
# func awake() -> void:		# unpause
# func reset() -> void:		# reset
# func death() -> void:		# gameover

# _menu.on_start.connect(start)
# _menu.on_sleep.connect(sleep)
# _menu.on_awake.connect(awake)
# _menu.on_reset.connect(reset)

signal on_start																	# buttons triggers signals
signal on_sleep																	# handles pause / unpause checks
signal on_awake
signal on_reset

const START_TEXT: String = "Space to Start"
const CONTINUE_TEXT: String = "Space to Continue"
const GAMEOVER_TEXT: String = "Game Over\n"
const GAMEOVER_RESET_TEXT: String = "Game Over\nAny Key to Reset"

var _can_start: bool = true														# avoid immediately start on gameover
var _is_started: bool = false
var _is_paused: bool = false													# keep pause logic checks here
var _is_key_released: bool = true												# avoid quick pause / unpause
var _is_reset_finished: bool = false											# reset only on held finish

@onready var _buttons := get_child(0) as Control
@onready var _btn_start := _buttons.get_child(0) as MyButton
@onready var _btn_pause := _buttons.get_child(1) as MyButton
@onready var _btn_reset := _buttons.get_child(2) as MyButton
@onready var _prg_circle := _btn_reset.get_child(0) as MyProgressCircle
@onready var _lbl_paused := get_child(1).get_child(0) as Label
@onready var _lbl_middle := get_child(1).get_child(1) as Label


func _ready() -> void:
	_btn_start.button_down.connect(_on_start_pressed)
	_btn_pause.button_down.connect(_on_pause_pressed)
	_btn_reset.button_down.connect(_on_reset_pressed)
	_btn_reset.button_up.connect(_on_reset_released)
	_prg_circle.on_finish.connect(_on_reset_finished)

	_btn_start.visible = true
	_btn_pause.visible = false
	_btn_reset.visible = false

	_lbl_paused.visible = false
	_lbl_middle.visible = true


func _unhandled_key_input(event: InputEvent) -> void:
	var key_event: = event as InputEventKey
	var key: Key = key_event.keycode

	if key_event.pressed == true:
		if _can_start == false:
			return

		if _is_started == false:
			if key == KEY_SPACE:												# game start
				start()

		elif key == KEY_ESCAPE || key == KEY_SPACE || key == KEY_P:

			if _is_key_released == false:
				return
			_is_key_released = false

			if _is_paused == false:												# pause
				sleep()
			elif _is_paused == true:											# unpause
				awake()

		elif key == KEY_R:														# reset start
			if _is_paused == true:												# only when paused
				_on_reset_pressed()

	elif key_event.pressed == false:
		if key == KEY_R:
			if _is_paused == true:
				_on_reset_released()											# reset or cancel

		elif key == KEY_ESCAPE || key == KEY_SPACE || key == KEY_P:
			if _is_key_released == false:										# avoid quick pause / unpause
				_is_key_released = true
				return


func started_set(has_started: bool = false) -> void:
	if has_started == false:
		_lbl_middle.text = START_TEXT

	elif has_started == true:
		_lbl_middle.text = CONTINUE_TEXT

		_btn_reset.visible = true												# enable reset
		_is_paused = true


func start() -> void:															# new game
	_btn_start.visible = false
	_btn_pause.visible = true
	_btn_reset.visible = false

	_lbl_paused.visible = false
	_lbl_middle.visible = false

	on_start.emit()																# signal on button press
	_is_started = true


func sleep() -> void:															# pause
	_btn_start.visible = true
	_btn_pause.visible = false
	_btn_reset.visible = true

	_lbl_paused.visible = true
	_lbl_middle.visible = true
	_lbl_middle.text = CONTINUE_TEXT

	on_sleep.emit()
	_is_paused = true


func awake() -> void:
	_btn_start.visible = false
	_btn_pause.visible = true
	_btn_reset.visible = false

	_lbl_paused.visible = false
	_lbl_middle.visible = false

	on_awake.emit()
	_is_paused = false


func reset() -> void:
	_btn_start.visible = true
	_btn_pause.visible = false
	_btn_reset.visible = false

	_lbl_paused.visible = false
	_lbl_middle.visible = true
	_lbl_middle.text = START_TEXT

	on_reset.emit()
	_is_started = false


func death() -> void:
	_lbl_paused.visible = false
	_lbl_middle.visible = true
	_lbl_middle.text = GAMEOVER_TEXT

	_btn_start.visible = false
	_btn_pause.visible = false
	_btn_reset.visible = false

	_is_paused = false
	_can_start = false


func after() -> void:
	_lbl_middle.text = GAMEOVER_RESET_TEXT


func renew() -> void:
	_btn_start.visible = true
	_btn_pause.visible = false
	_btn_reset.visible = false

	_lbl_paused.visible = false
	_lbl_middle.visible = true
	_lbl_middle.text = START_TEXT

	_is_started = false
	_can_start = true


func _on_start_pressed() -> void:
	if _is_started == false:
		start()

	elif _is_paused == true:
		awake()


func _on_pause_pressed() -> void:
	sleep()


func _on_reset_pressed() -> void:
	_prg_circle.start()
	_is_reset_finished = false


func _on_reset_released() -> void:
	_prg_circle.stop()															# must always call on release

	if _is_reset_finished == true:
		_is_reset_finished = false
		reset()


func _on_reset_finished() -> void:
	_is_reset_finished = true
