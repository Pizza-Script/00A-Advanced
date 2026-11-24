@tool
class_name MyIDE
extends EditorPlugin

# based on "JetBrains Rider Integration"

var _check_button: CheckButton


func _enter_tree() -> void:
	_load_ide_button()


func _exit_tree() -> void:
	if _check_button != null:
		remove_control_from_container(EditorPlugin.CONTAINER_TOOLBAR, _check_button)
		_check_button.queue_free()


func _load_ide_button() -> void:												# based on "JetBrains Rider Integration"
	var _config_path = get_script().get_path().get_base_dir() + "/plugin.cfg"
	var _config_file := ConfigFile.new()

	var _is_active: bool = true
	if FileAccess.file_exists(_config_path) == true:
		_config_file.load(_config_path)

		if _config_file.has_section_key("custom", "active") == true:
			_is_active = _config_file.get_value("custom", "active")
		else:
			_config_file.set_value("custom", "active", true)

	var result: = _config_file.save(_config_path)								# save file
	if result != OK:
		print(result)
		return

	_check_button = CheckButton.new()
	_check_button.text = "Use IDE"
	_check_button.tooltip_text = "enable the use of External IDE"
	_check_button.button_pressed = _is_active
	_check_button.pressed.connect(_on_ide_button_pressed)
	add_control_to_container(EditorPlugin.CONTAINER_TOOLBAR, _check_button)

	_apply_settings(_is_active)													# initial load


func _apply_settings(is_active: bool) -> void:
	var _editor_settings: = EditorInterface.get_editor_settings()
	_editor_settings.set_setting("text_editor/external/use_external_editor", is_active)
	# _editor_settings.set_setting("text_editor/behavior/files/auto_reload_scripts_on_external_change", is_active)


func _on_ide_button_pressed() -> void:
	var _is_active: bool = _check_button.button_pressed
	var _config_path = get_script().get_path().get_base_dir() + "/plugin.cfg"
	var _config_file: = ConfigFile.new()

	if FileAccess.file_exists(_config_path) == true:
		_config_file.load(_config_path)
	_config_file.set_value("custom", "active", _is_active)

	var result: = _config_file.save(_config_path)								# save file
	if result != OK:
		print(result)
		return

	_apply_settings(_is_active)
