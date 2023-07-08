extends CharacterBody2D

@export var speed = 150
@export var dir = Vector2.RIGHT

var gravity = Vector2.DOWN * 30

func _physics_process(delta):
	velocity.x = dir.x * speed
	velocity += gravity
	move_and_slide()

func _on_pickup_sound_finished():
	queue_free()


func _on_area_2d_body_entered(body):
	body.increase_score()
	hide()
	$PickupSound.play()
