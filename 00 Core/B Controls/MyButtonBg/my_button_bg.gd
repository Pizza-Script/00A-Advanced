@tool
class_name MyButtonBg
extends MyButton

# if no image, will show backgroudn & border

# signal pressed
# signal button_down
# signal button_up

# .enable()
# .disable()

@export var _is_enabled: bool = true
@export var _is_bordered: bool = true
@export var _image: Texture2D
@export var _image_margin: int = 5
@export var _background_color: Color = Color("124e89")
@export var _border_color: Color = Color("ffffff")
@export var _title: String = "BUTTON BG"
@export var _label_settings: LabelSettings
@export_tool_button("Create", "FadeDisabled") var create = _create

@onready var _nine_patch: = get_child(0) as NinePatchRect
@onready var _background: = get_child(1) as ColorRect
@onready var _border: = get_child(2) as ReferenceRect
@onready var _label: = get_child(3) as Label


func _ready() -> void:
	await get_tree().process_frame
	_layout()
	_values()


func _create() -> void:															# check if nodes exist
	if _nine_patch == null:														# create if missing
		_nine_patch = NinePatchRect.new()
		add_child(_nine_patch)
		_nine_patch.owner = self
		_nine_patch.name = "NinePatchRect"

	if _background == null:
		_background = ColorRect.new()
		add_child(_background)
		_background.owner = self
		_background.name = "Background"

	if _border == null:
		_border = ReferenceRect.new()
		add_child(_border)
		_border.owner = self
		_border.name = "Border"

	if _label == null:
		_label = Label.new()
		add_child(_label)
		_label.owner = self
		_label.name = "Label"

	await get_tree().process_frame
	_layout()
	_values()


func _layout() -> void:															# default values
	_nine_patch.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_nine_patch.texture = _image
	_nine_patch.patch_margin_left = _image_margin
	_nine_patch.patch_margin_right = _image_margin
	_nine_patch.patch_margin_top = _image_margin
	_nine_patch.patch_margin_bottom = _image_margin
	_nine_patch.modulate = _background_color

	_background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_background.mouse_filter = Control.MOUSE_FILTER_PASS
	_background.color = _background_color

	_border.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_border.mouse_filter = Control.MOUSE_FILTER_PASS
	_border.border_color = _border_color
	_border.editor_only = false

	_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_label.mouse_filter = Control.MOUSE_FILTER_PASS
	_label.label_settings = _label_settings
	_label.position.x -= 1
	_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.text = _title


func _values() -> void:
	if _is_enabled == true:
		enable()
	else:
		disable()

	if _is_bordered == true:
		_border.visible = true
	else:
		_border.visible = false

	if _image == null:
		_nine_patch.visible = false
		_background.visible = true
		_border.visible = true
	else:
		_nine_patch.visible = true
		_background.visible = false
		_border.visible = false
