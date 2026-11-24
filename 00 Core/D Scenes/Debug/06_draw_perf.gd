class_name DrawPerf
extends Node2D

var _fps_array: Array[float] = []
var _fps_cur: float = 0.0
var _fps_avg: float = 0.0
var _fps_min: float = 0.0
var _fps_max: float = 0.0
var _fps_spent: float = 0.0

func _ready() -> void:
	MyDraw.draw.connect(_on_draw)
	MyDraw.queue_redraw()


func _on_draw() -> void:
	MyDraw.text_auto_camera("%03d SEC" % (Time.get_ticks_msec() / 1000))
	MyDraw.text_auto_camera("%03d FPS - %03d AVG" % [_fps_cur, _fps_avg])
	MyDraw.text_auto_camera("%03d MIN - %03d MAX" % [_fps_min, _fps_max])


func _process(delta: float) -> void:
	_fps_spent -= delta
	if _fps_spent <= 0.0:
		_fps_spent = 1.0

		_fps_cur = Engine.get_frames_per_second()
		_fps_array.append(_fps_cur)

		if _fps_array.size() > 60:
			_fps_array.pop_front()

		# _fps_avg = MyArray.averagef(_fps_array)
		_fps_avg = MyUtil.array_average_f(_fps_array)
		_fps_min = _fps_array.min()
		_fps_max = _fps_array.max()

		MyDraw.queue_redraw()
