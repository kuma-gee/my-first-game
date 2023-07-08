extends CharacterBody2D

signal left_screen

@export var accel := 800
@export var speed := 400

@onready var collision := $CollisionShape2D
@onready var body := $Body
@onready var anim := $AnimationPlayer

var gravity = Vector2.DOWN * 3 # First time should be slower

var gravity_enabled := true
var input_enabled := false
var flip_enabled := false
var accel_enabled := false
var anim_enabled := false

func _physics_process(delta):
	if input_enabled:
		var motion = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
		
		if accel_enabled:
			if abs(motion) > 0:
				velocity.x = move_toward(velocity.x, motion * speed, accel * delta)
			else:
				velocity.x = move_toward(velocity.x, 0, accel * delta)
		else:
			velocity.x = motion * speed
		
		if flip_enabled:
			if abs(motion) > 0:
				body.scale.x = sign(motion)
				
		if anim_enabled:
			if velocity.length() > 0:
				anim.play("run")
			else:
				anim.play("idle")
	
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
	
func enable_anim():
	anim_enabled = true
	
func enable_accel():
	accel_enabled = true

func _on_visible_on_screen_notifier_2d_screen_exited():
	left_screen.emit()
	gravity_enabled = false
	velocity /= 2 # make slower so cursor can catch it
