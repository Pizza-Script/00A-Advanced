@tool
class_name ShopNestedItem
extends MyButton

@onready var _image: = get_child(0) as TextureRect
@onready var _lbl_level: = get_child(1) as Label
@onready var _lbl_title: = get_child(2) as Label


func _ready() -> void:
	super()																		# run MyButton _ready()


func set_level(level: int) -> void:
	_lbl_level.text = "%02d" % level


func set_title(title: String) -> void:
	_lbl_title.text = title


func set_icon(icon: Texture2D) -> void:
	_image.texture = icon
