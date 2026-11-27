@tool
class_name ShopItem
extends MyButton

@export var _info: ShopInfo

@export var unlock_start: bool													# unlocked on game load
@export var unlock_target: Dictionary[ShopItem, int]							# unlock item(s) on level reach

var index: int

var _level: int
var _level_max: int

@onready var _image: = get_child(0) as TextureRect
@onready var _lbl_level: = get_child(1) as Label
@onready var _lbl_title: = get_child(2) as Label


func _ready() -> void:
	super()																		# run MyButton _ready()

	visible = false

	if _info == null:
		printerr("Missing Info: %s" % [name])
		return

	index = _info.index
	_lbl_title.text = _info.title
	_level_max = _info.level_max


func set_level(level: int) -> void:
	_level = level
	_lbl_level.text = "%02d" % _level


func unlock_check() -> void:
	if unlock_start == true:
		_unlock()

	for target in unlock_target:
		if target.visible == true:
			continue

		if _level >= unlock_target[target]:
			_unlock()


func _unlock() -> void:
	visible = true


#region Tools
func set_icon(icon: Texture2D) -> void:
	_image.texture = icon


func set_info(info: ShopInfo) -> void:
	_info = info

	index = _info.index
	_lbl_title.text = _info.title
	_level_max = _info.level_max


func get_info() -> ShopInfo:
	return _info

#endregion
