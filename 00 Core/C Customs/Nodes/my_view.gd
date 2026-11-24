@tool
class_name MyView
extends Control

@export_range(0.5, 5.0, 0.5) var _scale: float = 2.0
@export_tool_button("Apply", "ImportCheck") var apply = _apply

var _viewport_size: Vector2 = MyCore.viewport_size


func _ready() -> void:
	MyCore.on_viewport_edit.connect(_on_viewport_edit)

	set_size.call_deferred(_viewport_size)
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _apply() -> void:
	scale = Vector2.ONE * _scale


func _on_viewport_edit() -> void:
	_viewport_size = MyCore.viewport_size
	set_size.call_deferred(_viewport_size)
