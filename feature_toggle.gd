extends HBoxContainer

signal toggled

@export var text := ""
@onready var label := $Label
@onready var btn: TextureButton = $TextureButton

func _ready():
	label.text = text

func toggle():
	btn.button_pressed = true
	await get_tree().create_timer(0.3).timeout
	toggled.emit()
	btn.disabled = true
	btn.button_pressed = false
