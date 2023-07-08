extends CharacterBody2D

@export var speed = 150
@export var dir = Vector2.RIGHT
@export var color := Color.WHITE

@onready var anim := $AnimationPlayer

@onready var spike := $Spike
@onready var robot := $Robot

var gravity = Vector2.DOWN * 30
var switch_color = false

var colors_enabled = false
var effect_enabled = false

func _ready():
	spike.visible = not GameManager.unlocked_better_graphics()
	robot.visible = GameManager.unlocked_better_graphics()
	robot.flip_h = sign(dir.x) == -1
	
	if colors_enabled:
		spike.modulate = color

func _physics_process(delta):
	velocity.x = dir.x * speed
	velocity += gravity
	move_and_slide()
	
	if effect_enabled and not anim.is_playing():
		anim.play("move")

func enable_effect():
	effect_enabled = true

func _process(delta):
	if colors_enabled and spike.modulate != color and not switch_color:
		switch_color = true
		create_tween().tween_property(spike, "modulate", color, 1.0)

func _on_hit_box_body_entered(body):
	var pos = body.global_position + Vector2.UP * 10
	body.damage(global_position.direction_to(pos))
