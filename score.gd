extends CharacterBody2D

@export var speed = 150
@export var dir = Vector2.RIGHT

@onready var rect := $Area2D/CollisionShape2D/Rect
@onready var coin := $Area2D/CollisionShape2D/Coin

var gravity = Vector2.DOWN * 30

func _ready():
	rect.visible = not GameManager.unlocked_better_graphics()
	coin.visible = GameManager.unlocked_better_graphics()

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
