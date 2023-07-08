extends StaticBody2D

@onready var rect := $ColorRect
@onready var sprite := $Sprite2D

func _ready():
	rect.visible = not GameManager.unlocked_better_graphics()
	sprite.visible = GameManager.unlocked_better_graphics()
