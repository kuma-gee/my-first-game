extends Area2D

@export var speed := 800
@export var default_player_pos: Marker2D

var catching_enabled = false

var catching_player = null
var caught = false

var original_pos = null

func _physics_process(delta):
	if catching_player == null or not catching_enabled:
		if original_pos != null:
			_move_to(original_pos, delta)
			if _is_close_to(original_pos):
				original_pos = null
		return
	
	if caught:
		_move_to(default_player_pos.global_position, delta)
		catching_player.global_position = global_position
		
		if _is_close_to(default_player_pos.global_position):
			catching_player.enable_gravity()
			caught = false
			catching_player = null
	else:
		_move_to(catching_player.global_position, delta)

func _move_to(pos: Vector2, delta: float):
	var dir = global_position.direction_to(pos)
	global_position += dir * speed * delta

func _is_close_to(pos: Vector2):
	var dist = global_position.distance_to(pos)
	return dist < 5
	
func enable_catch():
	catching_enabled = true

func catch_player(player: Node2D):
	if catching_enabled:
		caught = false
		catching_player = player
		original_pos = global_position

func _on_body_entered(body):
	caught = true
