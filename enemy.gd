extends CharacterBody2D

@export var speed = 150
@export var dir = Vector2.RIGHT
@export var color := Color.WHITE

var gravity = Vector2.DOWN * 30
var colors_enabled = false
var switch_color = false

func _ready():
	if colors_enabled:
		modulate = color

func _physics_process(delta):
	velocity.x = dir.x * speed
	velocity += gravity
	move_and_slide()
	
func _process(delta):
	if colors_enabled and modulate != color and not switch_color:
		switch_color = true
		create_tween().tween_property(self, "modulate", color, 1.0)

func _on_hit_box_body_entered(body):
	body.damage(global_position.direction_to(body.global_position))
