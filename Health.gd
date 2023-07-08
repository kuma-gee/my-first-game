extends Control

@onready var rect := $ColorRect
@onready var tex := $TextureRect
@onready var anim := $AnimationPlayer

var original_pos := position
var removed = false
var tw: Tween

func _ready():
	rect.visible = not GameManager.unlocked_better_graphics()
	tex.visible = GameManager.unlocked_better_graphics()

func lost_hp():
	if removed: return
	
	removed = true
	original_pos = position
	
	if tw:
		tw.kill()
	
	tw = create_tween()
	tw.tween_property(self, "modulate", Color.TRANSPARENT, 0.5)
	tw.parallel().tween_property(self, "position", position + Vector2.UP * 10, 0.5)

func heal_hp():
	if not removed: return
	
	removed = false
	position = original_pos
	scale = Vector2(0.5, 0.5)
	
	if tw:
		tw.kill()
	
	tw = create_tween()
	tw.tween_property(self, "modulate", Color.WHITE, 0.5)
	tw.parallel().tween_property(self, "scale", Vector2(1, 1), 0.5) \
		.set_ease(Tween.EASE_IN_OUT) \
		.set_trans(Tween.TRANS_BOUNCE)
	

func pulse():
	anim.play("pulse")

func stop_pulse():
	anim.play("RESET")
