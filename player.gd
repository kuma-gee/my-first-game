extends CharacterBody2D

signal left_screen

@export var speed := 100

@onready var collision := $CollisionShape2D
@onready var sprite := $Sprite2D

var gravity = Vector2.DOWN * 2 # First time should be slower

var gravity_enabled := true
var input_enabled := false
var flip_enabled := false

func _physics_process(delta):
	if input_enabled:
		var motion = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
		velocity.x = motion * speed
		
		if flip_enabled:
			if motion > 0:
				sprite.flip_h = sign(motion)
	
	if gravity_enabled:
		velocity += gravity
		
	move_and_slide()

func enable_collision():
	collision.disabled = false

func enable_input():
	input_enabled = true

func enable_flip():
	flip_enabled = true

func enable_gravity():
	gravity_enabled = true
	gravity = Vector2.DOWN * 30

func _on_visible_on_screen_notifier_2d_screen_exited():
	left_screen.emit()
	gravity_enabled = false
	velocity /= 2 # make slower so cursor can catch it
