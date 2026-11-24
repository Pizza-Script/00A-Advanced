@tool
class_name MyLabel
extends Label

@export_tool_button("Apply", "ImportCheck") var apply = _apply


func _apply() -> void:
	label_settings = preload("uid://bpwrgbrynbirg")
	set_script(null)															# remove script after
