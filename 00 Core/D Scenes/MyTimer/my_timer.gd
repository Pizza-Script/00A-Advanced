class_name MyTimer
extends Label

signal on_end
signal on_minute

@export var _is_countdown: bool
@export var _start_time: int

var current_time: int

var _seconds_spent: float = 0.0
var _seconds_timer: float = 1.0

var _minutes: int = 0
var _seconds: int = 0


func _ready() -> void:
	set_process(false)
	enter()


func _process(delta: float) -> void:
	_seconds_spent += delta
	if _seconds_spent >= _seconds_timer:
		_seconds_spent = 0.0

		if _is_countdown == true:
			current_time -= 1
		elif _is_countdown == false:
			current_time += 1

		_minutes = (current_time / 60) % 60
		_seconds = current_time % 60
		text = "%02d:%02d" % [_minutes, _seconds]

		if _seconds == 0:
			on_minute.emit()

	if _is_countdown == true && current_time == 0:
		on_end.emit()
		set_process(false)


func enter(time: int = -1) -> void:
	if time == -1:
		current_time = _start_time
	else:
		current_time = time

	_minutes = (current_time / 60) % 60
	_seconds = current_time % 60
	text = "%02d:%02d" % [_minutes, _seconds]


func start() -> void:
	set_process(true)


func pause() -> void:
	set_process(false)


func reset(time: int = -1) -> void:
	if time == -1:
		current_time = _start_time
	else:
		current_time = time

	_minutes = (current_time / 60) % 60
	_seconds = current_time % 60
	text = "%02d:%02d" % [_minutes, _seconds]
	set_process(false)


func death() -> void:
	set_process(false)
