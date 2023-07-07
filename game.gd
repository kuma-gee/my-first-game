extends Node2D

const PLACE_TILE_DELAY = 0.1
const PLACE_PLAYER_DELAY = 0.5
const PLAYER_MOVEMENT_DELAY = 2.0

@onready var map := $TileMap
@onready var anim := $AnimationPlayer
@onready var player := $Player
@onready var cursor := $Cursor

func _ready():
	map.clear()

func _wait(sec):
	await get_tree().create_timer(sec).timeout

func build_first_platform():
	var cells = []
	for y in range(2, 3):
		for x in range(-6, 6):
			var coord = Vector2i(x, y)
			cells.append(coord)
			map.set_cell(0, coord, 1, Vector2(2, 0))
			await _wait(PLACE_TILE_DELAY)

#	map.set_cells_terrain_connect(0, cells, 0, 0)
	
	await _wait(PLACE_PLAYER_DELAY)
	anim.play("place_player")

func improve_player_movement():
	await _wait(PLAYER_MOVEMENT_DELAY)
	anim.play("enable_player_move")

func _on_player_left_screen():
	cursor.catch_player(player)
