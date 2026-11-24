class_name MenuToggle
extends Control

@export var img_menu: Texture2D = preload("menu.png")
@export var img_close: Texture2D = preload("close.png")

var _menu_open: bool = false

@onready var _pnl_main := get_child(0) as Panel
@onready var _btn_menu := get_child(1) as MyButton


func _ready() -> void:
	_btn_menu.pressed.connect(func(): _toggle_menu())

	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

	_btn_menu.texture_normal = img_menu
	_pnl_main.visible = false


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and (event as InputEventKey).pressed:

		var key: Key = (event as InputEventKey).keycode
		if key == KEY_ESCAPE:
			_toggle_menu()


func _toggle_menu() -> void:
	if _menu_open == true:
		_menu_open = false
		_pnl_main.visible = false
		_btn_menu.texture_normal = img_menu
	elif _menu_open == false:
		_menu_open = true
		_pnl_main.visible = true
		_btn_menu.texture_normal = img_close
