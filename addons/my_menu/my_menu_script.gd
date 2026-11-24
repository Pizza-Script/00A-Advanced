@tool
class_name MyMenuScript
extends EditorContextMenuPlugin

# sample code [reddit.com/r/godot/comments/1morndn]
# added in 4.4 [github.com/godotengine/godot/pull/96539]

enum Fix
{
	TABS,
	FOLD,
	UNFOLD,
}

enum Code
{
	SIGNAL,
	STATIC,
	CONST,
	ENUM,
	EXPORT,
	READY,
	AWAIT,
	EDITOR,
}

enum Func
{
	DRAW,
	SIGNAL,
	MOUSE,
	KEY,
}


func _popup_menu(paths: PackedStringArray):
	var code_edit: = Engine.get_main_loop().root.get_node(paths[0]) as CodeEdit;

	var fix_code_menu: = PopupMenu.new()
	fix_code_menu.add_item("Spaces to Tabs", Fix.TABS)
	fix_code_menu.add_item("Fold All Code", Fix.FOLD)
	fix_code_menu.add_item("Unfold All Code", Fix.UNFOLD)
	fix_code_menu.id_pressed.connect(_on_fix_submenu_option.bind(code_edit))
	add_context_submenu_item("Fix Code", fix_code_menu)

	var add_code_menu: = PopupMenu.new()
	add_code_menu.add_item("Add signal", Code.SIGNAL)
	add_code_menu.add_item("Add static", Code.STATIC)
	add_code_menu.add_item("Add const", Code.CONST)
	add_code_menu.add_item("Add enum", Code.ENUM)
	add_code_menu.add_item("Add @export", Code.EXPORT)
	add_code_menu.add_item("Add @onready", Code.READY)
	add_code_menu.add_item("Add await", Code.AWAIT)
	add_code_menu.add_item("Add editor hint", Code.EDITOR)
	add_code_menu.id_pressed.connect(_on_code_submenu_option.bind(code_edit))
	add_context_submenu_item("Add Code", add_code_menu)

	var add_func_menu: = PopupMenu.new()
	add_func_menu.add_item("Add _on_draw", Func.DRAW)
	add_func_menu.add_item("Add _on_signal", Func.SIGNAL)
	add_func_menu.add_item("Add _unhandled_input", Func.MOUSE)
	add_func_menu.add_item("Add _unhandled_key_input", Func.KEY)
	add_func_menu.id_pressed.connect(_on_func_submenu_option.bind(code_edit))
	add_context_submenu_item("Add Func", add_func_menu)


func _on_fix_submenu_option(id: int, code_edit: CodeEdit) -> void:
	match id:
		Fix.TABS:
			_spaces_to_tabs(code_edit)
		Fix.FOLD:
			code_edit.fold_all_lines()
		Fix.UNFOLD:
			code_edit.unfold_all_lines()


func _on_code_submenu_option(id: int, code_edit: CodeEdit) -> void:
	match id:
		Code.SIGNAL:
			code_edit.insert_text_at_caret("signal my_signal(my_int: int)")
		Code.STATIC:
			code_edit.insert_text_at_caret("static var my_int: int = 0")
		Code.CONST:
			code_edit.insert_text_at_caret("const MY_SPEED: int = 100")
		Code.ENUM:
			code_edit.insert_text_at_caret("enum MyEnum {}")
		Code.EXPORT:
			code_edit.insert_text_at_caret("@export var _texture: Texture2D")
		Code.READY:
			code_edit.insert_text_at_caret("@onready var _sprite: = get_child(0) as Sprite2D")
		Code.AWAIT:
			code_edit.insert_text_at_caret("await get_tree().process_frame")
		Code.EDITOR:
			code_edit.insert_text_at_caret("if Engine.is_editor_hint() == true:")


func _on_func_submenu_option(id: int, code_edit: CodeEdit) -> void:
	match id:
		Func.DRAW:
			_on_draw(code_edit)
		Func.SIGNAL:
			_on_signal(code_edit)
		Func.MOUSE:
			_unhandled_input(code_edit)
		Func.KEY:
			_unhandled_key_input(code_edit)


func _spaces_to_tabs(code_edit: CodeEdit) -> void:
	var caret_line: int = code_edit.get_caret_line()
	var all_code: String = code_edit.text
	all_code = all_code.replace("    ", "\t")
	all_code = all_code.replace("   ", "\t")
	all_code = all_code.replace("  ", "\t")
	all_code = all_code.replace("\t ", "\t\t")
	code_edit.text = all_code
	code_edit.set_caret_line(caret_line)										# move caret back


func _on_draw(code_edit: CodeEdit) -> void:
	var add_code: String = "MyDraw.draw.connect(_on_draw)
	MyDraw.queue_redraw()


func _on_draw() -> void:
	pass"

	code_edit.insert_text_at_caret(add_code)


func _on_signal(code_edit: CodeEdit) -> void:
	var function_string : String = code_edit.get_selected_text()
	var last_line: int = code_edit.get_line_count() - 1
	code_edit.insert_line_at(last_line, "\n\nfunc " + function_string + "() -> void:\n\tpass")
	code_edit.deselect()
	code_edit.set_caret_line(last_line + 3)
	code_edit.center_viewport_to_caret()


func _unhandled_input(code_edit: CodeEdit) -> void:
	var add_code: String = "func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse_event: = event as InputEventMouseButton

		if mouse_event.pressed == false:
			return

		if mouse_event.button_index == MOUSE_BUTTON_LEFT:
			pass

	if event is InputEventMouseMotion:
		var mouse_event: = event as InputEventMouseMotion"

	code_edit.insert_text_at_caret(add_code)


func _unhandled_key_input(code_edit: CodeEdit) -> void:
	var add_code: String = "func _unhandled_key_input(event: InputEvent) -> void:
	var key_event: = event as InputEventKey
	var key: Key = key_event.keycode

	if key_event.pressed == false:
		return

	if key_event.echo == true:
		return

	if key == KEY_T:
		pass"

	code_edit.insert_text_at_caret(add_code)
