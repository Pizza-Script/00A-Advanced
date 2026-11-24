class_name MenuAudio
extends Control

signal on_change(value: float)

@export var _audio_0: Texture2D
@export var _audio_1: Texture2D
@export var _audio_2: Texture2D

var _audio_index: int = 2

@onready var _btn_audio := get_child(0) as MyButton


func _ready() -> void:
	_btn_audio.pressed.connect(_on_btn_audio_pressed)

	_btn_audio.texture_normal = _audio_2


func _on_btn_audio_pressed() -> void:
	_audio_index -= 1
	if _audio_index == -1:
		_audio_index = 2

	match _audio_index:
		0:
			_btn_audio.texture_normal = _audio_0
			AudioServer.set_bus_volume_db(0, linear_to_db(0.0))
		1:
			_btn_audio.texture_normal = _audio_1
			AudioServer.set_bus_volume_db(0, linear_to_db(0.5))
		2:
			_btn_audio.texture_normal = _audio_2
			AudioServer.set_bus_volume_db(0, linear_to_db(1.0))

	on_change.emit(_audio_index)
