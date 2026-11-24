@tool
class_name MySplit
extends EditorPlugin

# based on "Script-IDE" by Maran23 [github.com/Maran23/script-ide]

var _tab_container: TabContainer
var _container_parent: Control
var _split_container: HSplitContainer
var _check_button: CheckButton


func _enter_tree() -> void:
	_load_ide_button()


func _exit_tree() -> void:
	if _split_container != null:
		_container_parent = _split_container.get_parent() as Control
		_tab_container.reparent(_container_parent)
		_container_parent.move_child(_tab_container, 1)
		_split_container.queue_free()

	if _check_button != null:
		_check_button.queue_free()


func _load_ide_button() -> void:												# based on "JetBrains Rider Integration"
	var script_editor: ScriptEditor = EditorInterface.get_script_editor()

	_tab_container = script_editor.find_children("*", "TabContainer", true, false)[0] as Control
	_container_parent = _tab_container.get_parent() as Control
	_split_container = HSplitContainer.new()
	_split_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_split_container.size_flags_vertical = Control.SIZE_EXPAND_FILL

	_container_parent.add_child(_split_container)
	_container_parent.move_child(_split_container, 0)
	_tab_container.reparent(_split_container)

	_check_button = CheckButton.new()
	_check_button.text = "Split"
	_check_button.alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_check_button.size_flags_horizontal = Control.SIZE_SHRINK_END
	_check_button.tooltip_text = "split view for script editing"
	_check_button.pressed.connect(_on_button_toggle)

	_container_parent.add_child(_check_button)								# TODO: wadd button to correct container
	_container_parent.move_child(_check_button, 0)							# NOTE: move to top


func _on_button_toggle() -> void:
	var script_editor: ScriptEditor = EditorInterface.get_script_editor()
	var script_editor_base: ScriptEditorBase = script_editor.get_current_editor()

	if _check_button.button_pressed == true:
		if script_editor_base == null:
			return

		var base_editor: Control = script_editor_base.get_base_editor()
		if base_editor is CodeEdit == false:
			return

		var script: Script = script_editor.get_current_script()
		_check_button.text = script.resource_path.get_file()					# name of currently active script

		var editor: CodeEdit = new_code_edit(base_editor)

		var container: PanelContainer = PanelContainer.new()
		container.custom_minimum_size.x = 200
		container.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		container.add_child(editor)
		_split_container.add_child(container)

	else:
		_check_button.text = "Split"
		_split_container.remove_child(_split_container.get_child(_split_container.get_child_count() - 1))


func new_code_edit(_code_edit: CodeEdit) -> CodeEdit:
	var my_code_edit: = CodeEdit.new()
	my_code_edit.editable = false
	my_code_edit.caret_draw_when_editable_disabled = true
	my_code_edit.set_caret_line.call_deferred(_code_edit.get_caret_line())
	my_code_edit.set_v_scroll.call_deferred(_code_edit.scroll_vertical)

	my_code_edit.text = _code_edit.text
	my_code_edit.syntax_highlighter = _code_edit.syntax_highlighter
	my_code_edit.highlight_all_occurrences = _code_edit.highlight_all_occurrences
	my_code_edit.highlight_current_line = _code_edit.highlight_current_line

	my_code_edit.use_default_word_separators = _code_edit.use_default_word_separators
	my_code_edit.use_custom_word_separators = _code_edit.use_custom_word_separators
	my_code_edit.custom_word_separators = _code_edit.custom_word_separators

	my_code_edit.line_folding = _code_edit.line_folding
	my_code_edit.line_length_guidelines = _code_edit.line_length_guidelines

	my_code_edit.gutters_draw_line_numbers = _code_edit.gutters_draw_line_numbers
	my_code_edit.gutters_draw_fold_gutter = _code_edit.gutters_draw_fold_gutter

	my_code_edit.minimap_draw = _code_edit.minimap_draw
	my_code_edit.minimap_width = _code_edit.minimap_width

	my_code_edit.delimiter_strings = _code_edit.delimiter_strings
	my_code_edit.delimiter_comments = _code_edit.delimiter_comments

	my_code_edit.indent_automatic = _code_edit.indent_automatic
	my_code_edit.indent_size = _code_edit.indent_size
	my_code_edit.indent_use_spaces = _code_edit.indent_use_spaces
	my_code_edit.indent_automatic_prefixes = _code_edit.indent_automatic_prefixes

	my_code_edit.draw_control_chars = _code_edit.draw_control_chars
	my_code_edit.draw_tabs = _code_edit.draw_tabs
	my_code_edit.draw_spaces = _code_edit.draw_spaces

	return my_code_edit
