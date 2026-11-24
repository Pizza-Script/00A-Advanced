@tool
class_name MyMenu
extends EditorPlugin

# added in 4.4 [github.com/godotengine/godot/pull/94582]

var _menu_location: EditorContextMenuPlugin.ContextMenuSlot
var _menu_script: EditorContextMenuPlugin = preload("my_menu_script.gd").new()


func _enter_tree() -> void:
	_menu_location = EditorContextMenuPlugin.CONTEXT_SLOT_SCRIPT_EDITOR_CODE	# menu location (script editor)
	add_context_menu_plugin(_menu_location, _menu_script)


func _exit_tree() -> void:
	remove_context_menu_plugin(_menu_script)
