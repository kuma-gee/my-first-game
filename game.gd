extends Node2D

const TILE_ATLAS = Vector2(0, 2)
const PLACE_TILE_DELAY = 0.05
const PLACE_PLAYER_DELAY = 0.5
const PLAYER_MOVEMENT_DELAY = 2.0

@onready var map := $TileMap
@onready var anim := $AnimationPlayer
@onready var player := $Player
@onready var cursor := $Cursor

var enclosed = false

func _ready():
	map.clear()

func _wait(sec):
	await get_tree().create_timer(sec).timeout

func build_first_platform():
	await _fill_range(Vector2(-6, 2), Vector2(5, 2))
	
	await _wait(PLACE_PLAYER_DELAY)
	anim.play("place_player")

func improve_player_movement():
	await _wait(PLAYER_MOVEMENT_DELAY)
	anim.play("enable_player_move")

func enclose_player():
	if enclosed: return
	
	var lowest_y = 4
	var highest_y = -6
	_fill_range(Vector2(-6, lowest_y - 1), Vector2(5, lowest_y), Vector2(1, 1), true)
	_fill_range(Vector2(6, lowest_y), Vector2(7, highest_y), Vector2(1, -1), true)
	await _fill_range(Vector2(-7, lowest_y), Vector2(-8, highest_y), Vector2(-1, -1), true)
	await _fill_range(Vector2(-8, highest_y + 2), Vector2(7, highest_y), Vector2(1, -1), true)
	
	# make sure terrain is updated
#	for coord in map.get_used_cells(0):
#		map.set_cells_terrain_connect(0, [coord], 0, 0)
#		await _wait(PLACE_TILE_DELAY / 2)
	enclosed = true

func _fill_range(start: Vector2, end: Vector2, diff = Vector2(1, 1), connect = false):
	for y in range(start.y, end.y + diff.y, diff.y):
		for x in range(start.x, end.x + diff.x, diff.x):
			var coord = Vector2i(x, y)
			
			if map.get_cell_tile_data(0, coord) == null:
				map.set_cell(0, coord, 1, TILE_ATLAS)
				await _wait(PLACE_TILE_DELAY)
			
#			if connect:
#				map.set_cells_terrain_connect(0, [coord], 0, 0)


func _on_player_left_screen():
	cursor.catch_player(player)


func _on_cursor_catch_finish():
	if not enclosed:
		enclose_player()
