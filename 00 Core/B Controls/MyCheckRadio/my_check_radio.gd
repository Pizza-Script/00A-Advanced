@tool
class_name MyCheckRadio
extends CheckBox

# NOTE: Group "Local to Scene" must be false
# if true, will duplicate ButtonGroup for each scene							# reddit.com/r/godot/comments/1be44sw

# .button_pressed = true
# .button_pressed_no_signal(is_pressed)

# .enable()
# .disable()

#region Images
@export_group("Images")
@export var _blank: Texture2D = preload("Texture/my_radio_blank.png")		# needed to hide native check
@export var _checked: Texture2D = preload("Texture/my_radio_checked.png")
@export var _unchecked: Texture2D = preload("Texture/my_radio_unchecked.png")
#endregion

@export_group("", "")
@export var _is_enabled: bool = true
@export var _is_checked: bool = false
@export var _title: String = "CHECK RADIO"
@export var _group: ButtonGroup = preload("my_check_radio_group.tres")
@export var _label_settings: LabelSettings
@export_tool_button("Create", "FadeDisabled") var create = _create

var _is_pressed: bool = false

@onready var _image: = get_child(0) as TextureRect
@onready var _lbl_title: = get_child(1) as Label


func _ready() -> void:
	toggled.connect(_on_toggle)

	await get_tree().process_frame
	_layout()
	_values()


func _create() -> void:															# check if nodes exist
	if _image == null:															# create if missing
		_image = TextureRect.new()
		add_child(_image)
		_image.owner = self
		_image.name = "Image"

	if _lbl_title == null:
		_lbl_title = Label.new()
		add_child(_lbl_title)
		_lbl_title.owner = self
		_lbl_title.name = "Label"

	await get_tree().process_frame
	_layout()
	_values()


func _layout() -> void:
	add_theme_icon_override("checked", _blank)
	add_theme_icon_override("unchecked", _blank)
	add_theme_icon_override("radio_checked", _blank)
	add_theme_icon_override("radio_unchecked", _blank)
	add_theme_icon_override("checked_disabled", _blank)
	add_theme_icon_override("unchecked_disabled", _blank)
	add_theme_icon_override("radio_checked_disabled", _blank)
	add_theme_icon_override("radio_unchecked_disabled", _blank)

	# _image.set_anchors_and_offsets_preset(Control.PRESET_CENTER_LEFT)			# don't auto position
	# _image.position.x += 4.0													# easier to re-arrange manually

	_lbl_title.label_settings = _label_settings

	process_mode = Node.PROCESS_MODE_ALWAYS 									# can press when paused
	focus_mode = Control.FOCUS_NONE												# avoid focus highlight


func _values() -> void:
	if _is_checked == true:
		_image.texture = _checked
	elif _is_checked == false:
		_image.texture = _unchecked

	set_pressed_no_signal(_is_checked)

	if _is_enabled == true:
		enable()
	elif _is_enabled == false:
		disable()

	_lbl_title.text = _title

	if _group == null:
		print("ERROR: must add a group to MyCheckGroup")
	else:
		_group.resource_local_to_scene = false
		button_group = _group


func enable() -> void:
	disabled = false
	modulate = "ffffff"
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

	if is_connected("mouse_entered", _on_mouse_entered) == false:				# avoid connecting again
		mouse_entered.connect(_on_mouse_entered)
		mouse_exited.connect(_on_mouse_exited)
		button_down.connect(_on_button_down)
		button_up.connect(_on_button_up)


func disable() -> void:
	disabled = true
	modulate = "ffffff4b"
	mouse_default_cursor_shape = Control.CURSOR_FORBIDDEN

	if is_connected("mouse_entered", _on_mouse_entered) == true:
		mouse_entered.disconnect(_on_mouse_entered)
		mouse_exited.disconnect(_on_mouse_exited)
		button_down.disconnect(_on_button_down)
		button_up.disconnect(_on_button_up)


func button_pressed_no_signal(toggle: bool) -> void:
	set_pressed_no_signal(toggle)

	if toggle == true:
		_image.texture = _checked
	elif toggle == false:
		_image.texture = _unchecked


func _on_mouse_entered() -> void:
	modulate = "dcdcdc"


func _on_mouse_exited() -> void:
	if _is_pressed == false:													# mouse held on exit (stay clicked)
		modulate = "ffffff"


func _on_button_down() -> void:
	_is_pressed = true
	modulate = "c0c0c0"															# mouse click


func _on_button_up() -> void:
	_is_pressed = false
	if is_hovered() == true:
		modulate = "dcdcdc"														# mouse released (hovered)
	else:
		modulate = "ffffff"														# mouse released (not hovered)


func _on_toggle(toggle: bool) -> void:
	if toggle == true:
		_image.texture = _checked
	elif toggle == false:
		_image.texture = _unchecked
