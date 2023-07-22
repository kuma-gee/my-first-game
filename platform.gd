extends StaticBody2D

@onready var rect := $ColorRect
@onready var sprite := $Sprite2D
@onready var collision := $CollisionShape2D

func _ready():
	rect.visible = not GameManager.unlocked_better_graphics()
	sprite.visible = GameManager.unlocked_better_graphics()
	disable()

func disable():
	collision.disabled = true
	modulate = Color.TRANSPARENT
	
func enable():
	create_tween().tween_property(self, "modulate", Color.WHITE, 1.0)
	collision.disabled = false
