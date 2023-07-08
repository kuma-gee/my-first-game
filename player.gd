extends CharacterBody2D

signal left_screen
signal double_jumped

@export var jump_force := 500
@export var accel := 800
@export var speed := 400

@onready var collision := $CollisionShape2D
@onready var body := $Body
@onready var anim := $AnimationPlayer
@onready var shake := $Shake

@onready var land_particles := $LandParticles
@onready var jump_sound := $Jump
@onready var jump_land_sound := $JumpLand
@onready var hit_sound: AudioStreamPlayer = $Hit

var gravity = Vector2.DOWN * 3 # First time should be slower

var gravity_enabled := true
var input_enabled := false
var flip_enabled := false
var accel_enabled := false
var anim_enabled := false
var jump_enabled := false
var floor_jump_enabled := false
var sound_enabled := false
var freeze_enabled := false
var shake_enabled := false
var effects_enabled := false

var knockback = Vector2.ZERO
var was_in_air = false

func _physics_process(delta):
	if input_enabled:
		var motion = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
		
		if accel_enabled:
			velocity.x = move_toward(velocity.x, motion * speed, accel * delta)
		else:
			velocity.x = motion * speed
		
		if flip_enabled:
			if abs(motion) > 0:
				body.scale.x = sign(motion)
				
		if knockback:
			velocity += knockback
			knockback = knockback.move_toward(Vector2.ZERO, 800 * delta)
		else:
			modulate = Color.WHITE
				
#		if anim_enabled:
#			if velocity.length() > 0:
#				anim.play("run")
#			else:
#				anim.play("idle")
	
	if sound_enabled:
		if was_in_air and is_on_floor():
			jump_land_sound.playing = true
			if effects_enabled:
				land_particles.emitting = true
		else:
			land_particles.emitting = false
	
	if jump_enabled:
		if Input.is_action_just_pressed("jump") and (not floor_jump_enabled or is_on_floor()):
			if not is_on_floor():
				double_jumped.emit()
			velocity += Vector2.UP * jump_force
			if sound_enabled:
				jump_sound.playing = true
	
	if gravity_enabled:
		velocity += gravity
	
	was_in_air = not is_on_floor()
	move_and_slide()

func damage(dir: Vector2):
	knockback = dir * 50
	if sound_enabled:
		hit_sound.playing = true
	
	if freeze_enabled:
		freeze(0.1, 0.05)
	
	if effects_enabled:
		modulate = Color(1.0, 0.0, 0.0, 0.8)

	if shake_enabled:
		shake.shake()

func freeze(time_scale: float, duration: float):
	Engine.time_scale = time_scale
	await get_tree().create_timer(duration * time_scale).timeout
	Engine.time_scale = 1

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

func enable_jump():
	jump_enabled = true

func enable_floor_jump():
	floor_jump_enabled = true

func enable_sound():
	sound_enabled = true

func enable_freeze():
	freeze_enabled = true
	
func enable_shake():
	shake_enabled = true
	
func enable_effects():
	effects_enabled = true

func _on_visible_on_screen_notifier_2d_screen_exited():
	left_screen.emit()
	gravity_enabled = false
	velocity /= 2 # make slower so cursor can catch it
