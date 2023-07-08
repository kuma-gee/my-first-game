extends Control

@onready var rect := $ColorRect
@onready var tex := $TextureRect
@onready var anim := $AnimationPlayer

var removed = false

func _ready():
	rect.visible = not GameManager.unlocked_better_graphics()
	tex.visible = GameManager.unlocked_better_graphics()

func lost_hp():
	if removed: return
	
	removed = true
	var tw = create_tween()
	tw.tween_property(self, "modulate", Color.TRANSPARENT, 0.5)
	tw.parallel().tween_property(self, "position", position + Vector2.UP * 10, 0.5)

func pulse():
	anim.play("pulse")
