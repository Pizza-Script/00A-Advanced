@tool
class_name MyOptionsDropdown
extends Control

# .enable()
# .disable()
# .set_options(options: PackedStringArray)

# .update_value(index: int)

signal value_changed(value: int)

enum ScrollWidth
{
	LABEL,
	FULL,
}

@export var _is_enabled: bool = true
@export var _title: String = "OPTION"
@export var _options: PackedStringArray = ["INDEX", "LIFETIME"]
@export var _default: int = 0
@export var _label_width: int = 64
@export var _scroll_height: int = 48
@export var _scroll_width: = ScrollWidth.LABEL
@export var _label_settings: LabelSettings
@export_tool_button("Create", "FadeDisabled") var create = _create

var _option_index: int
var _scroll_rect: Rect2															# to detect outside click

@onready var _label: = get_child(0) as Label
@onready var _button: = get_child(1) as MyButtonLabel

@onready var _color_rect: = get_child(2) as ColorRect
@onready var _scroll_menu: = get_child(3) as ScrollContainer
@onready var _vbox_container: = _scroll_menu.get_child(0) as VBoxContainer


func _ready() -> void:
	_button.button_down.connect(_on_button_down)

	await get_tree().process_frame
	_layout()
	_values()

	menu_hide()


func _create() -> void:															# check if nodes exist
	if _label == null:															# create if missing
		_label = Label.new()
		add_child(_label)
		_label.owner = self
		_label.name = "Label"

	if _button == null:
		_button = MyButtonLabel.new()
		add_child(_button)
		_button.owner = self
		_button.name = "Button"

	if _color_rect == null:
		_color_rect = ColorRect.new()
		add_child(_color_rect)
		_color_rect.owner = self
		_color_rect.name = "ColorRect"

	if _scroll_menu == null:
		_scroll_menu = ScrollContainer.new()
		add_child(_scroll_menu)
		_scroll_menu.owner = self
		_scroll_menu.name = "ScrollContainer"

	if _vbox_container == null:
		_vbox_container = VBoxContainer.new()
		add_child(_vbox_container)
		_vbox_container.owner = self
		_vbox_container.name = "VBoxContainer"

	await get_tree().process_frame
	_layout()
	_values()

	menu_hide()


func _layout() -> void:															# default values
	_label.set_anchors_and_offsets_preset(Control.PRESET_CENTER_LEFT)
	_label.label_settings = _label_settings
	_label.offset_transform_enabled = true
	_label.offset_transform_position.x = -1.0
	_label.text = _title

	_button.set_anchors_and_offsets_preset(Control.PRESET_RIGHT_WIDE)
	_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_button.set_alignment_x(HorizontalAlignment.HORIZONTAL_ALIGNMENT_RIGHT)
	_button.set_label(_options[_default])

	_scroll_menu.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	_scroll_menu.size.y = _scroll_height
	_scroll_menu.position.y = _label.size.y + 2.0
	_scroll_menu.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_ALWAYS
	_scroll_menu.z_index = RenderingServer.CANVAS_ITEM_Z_MAX

	if _scroll_width== ScrollWidth.FULL:
		_button.position.x -= size.x - _button.size.x							# target_size - current_size
		_button.size.x = size.x
		_scroll_menu.position.x -= size.x - _scroll_menu.size.x					# target_size - current_size
		_scroll_menu.size.x = (size.x + 12)

	elif _scroll_width== ScrollWidth.LABEL:
		_button.position.x -= _label_width - _button.size.x						# target_size - current_size
		_button.size.x = _label_width
		_scroll_menu.position.x -= (_label_width) - _scroll_menu.size.x					# target_size - current_size
		_scroll_menu.size.x = (_label_width + 12)

	_color_rect.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	_color_rect.position = _scroll_menu.position
	_color_rect.size = _scroll_menu.size
	_color_rect.z_index = RenderingServer.CANVAS_ITEM_Z_MAX


func _values() -> void:
	if _is_enabled == true:
		enable()
	else:
		disable()

	_option_index = _default
	_scroll_rect = Rect2(Vector2(), _scroll_menu.size)

	for child in _vbox_container.get_children():
		child.queue_free()

	var index: int = 0
	var button_new: MyButtonLabel
	for option in _options:
		button_new = _button.duplicate() as MyButtonLabel
		button_new.set_label.call_deferred(option)
		button_new.set_alignment_x.call_deferred(HorizontalAlignment.HORIZONTAL_ALIGNMENT_RIGHT)
		button_new.custom_minimum_size = _button.size
		button_new.button_down.connect(_on_option_select.bind(index))

		_vbox_container.add_child(button_new)
		button_new.owner = get_tree().edited_scene_root							# ERROR: Owner must be ancestor in tree
		button_new.name = option												# must add first, before can name change
		index += 1


func _input(event):
	if event is InputEventMouseButton:
		var mouse_event: = event as InputEventMouseButton

		if mouse_event.pressed == false:
			return

		if _scroll_menu.visible == false:
			return

		if mouse_event.button_index == MOUSE_BUTTON_LEFT:
			if Rect2(Vector2(), _scroll_menu.size).has_point(_scroll_menu.get_local_mouse_position()) == false:
				menu_hide()


func update_value(index: int, _has_signal: bool = false) -> void:
	_option_index = index

	_button.set_label(_options[_option_index])
	if _has_signal == true:
		value_changed.emit(_option_index)


func set_options(options: PackedStringArray) -> void:
	_options = options
	_values()


func enable() -> void:
	_label.modulate = "ffffff"
	_button.modulate = "ffffff"
	_button.enable()


func disable() -> void:
	_label.modulate = "ffffff4b"
	_button.modulate = "ffffff4b"
	_button.disable()


func menu_show() -> void:
	_color_rect.visible = true
	_scroll_menu.visible = true


func menu_hide() -> void:
	_color_rect.visible = false
	_scroll_menu.visible = false


func menu_toggle() -> void:
	if _color_rect.visible == false:
		menu_show()

	elif _color_rect.visible == true:
		menu_hide()


func _on_button_down() -> void:
	menu_toggle()


func _on_option_select(index: int) -> void:
	update_value(index, true)
	menu_hide()
