class_name MyLabelShow
extends Label

# show on .enable()

@export var _length: float = 20.0
@export var _time: float = 1.5

var _tween: Tween


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	modulate.a = 0.0


func enable(start_pos: Vector2 = Vector2.INF) -> void:
	if start_pos.is_finite() == false:
		start_pos = position
	else:
		position = start_pos

	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(self, "modulate:a", 1.0, 0.2)
	_tween.parallel().tween_property(self, "position:y", -_length, _time).as_relative()
	_tween.tween_property(self, "modulate:a", 0.0, 0.2)
	_tween.tween_callback(func(): position = start_pos)
