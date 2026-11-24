class_name MySkybox
extends ColorRect

@export var _color: Color = "0311069d"


func _ready() -> void:
	color = _color
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
