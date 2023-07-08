extends Node2D

const TILE_ATLAS = Vector2(0, 0)
const PLACE_TILE_DELAY = 0.05
const PLACE_PLAYER_DELAY = 0.5

const PLATFORM_SPAWN_DELAY = 0.5
const PLATFORM_SCENE = preload("res://platform.tscn")

@onready var map := $TileMap
@onready var anim := $AnimationPlayer
@onready var player := $Player
@onready var cursor := $Cursor
@onready var bgm := $BGM

@onready var bot_spawn_l := $BotSpawnerL
@onready var bot_spawn_r := $BotSpawnerR
@onready var bot_spawn_lt := $BotSpawnerL2
@onready var bot_spawn_rt := $BotSpawnerR2

var enclosed = false
var platform_positions = []

func _ready():
	map.clear()
	for child in map.get_children():
		platform_positions.append(child.global_position)
		map.remove_child(child)

func _wait(sec):
	await get_tree().create_timer(sec).timeout

func build_first_platform():
	await _fill_range(Vector2(-10, 6), Vector2(9, 6))
	
	await _wait(PLACE_PLAYER_DELAY)
	anim.play("place_player")

func enclose_player():
	if enclosed: return
	
	var lowest_y = 7
	var highest_y = -9
	_fill_range(Vector2(-10, lowest_y - 1), Vector2(9, lowest_y), Vector2(1, 1))
	_fill_range(Vector2(10, lowest_y), Vector2(12, highest_y), Vector2(1, -1))
	await _fill_range(Vector2(-11, lowest_y), Vector2(-13, highest_y), Vector2(-1, -1))
	await _fill_range(Vector2(-11, highest_y + 2), Vector2(10, highest_y), Vector2(1, -1))
	
	# make sure terrain is updated
#	for coord in map.get_used_cells(0):
#		map.set_cells_terrain_connect(0, [coord], 0, 0)
#		await _wait(PLACE_TILE_DELAY / 2)
	enclosed = true
	if anim.is_playing():
		await anim.animation_finished
	anim.play("platforms")
	
func show_platforms():
	for pos in platform_positions:
		var platform = PLATFORM_SCENE.instantiate()
		platform.global_position = pos
		map.add_child(platform)
		await _wait(PLATFORM_SPAWN_DELAY)
	
	anim.play("enemies")

func spawn_bot_enemies():
	_fill_range(Vector2(-13, 5), Vector2(-11, 5), Vector2(1, 1), -1)
	await _fill_range(Vector2(10, 5), Vector2(12, 5), Vector2(1, 1), -1)
	bot_spawn_l.enabled = true
	bot_spawn_r.enabled = true

func spawn_top_enemies():
	_fill_range(Vector2(-8, -7), Vector2(-8, -7), Vector2(1, 1), -1)
	await _fill_range(Vector2(7, -7), Vector2(7, -7), Vector2(1, 1), -1)
	bot_spawn_lt.enabled = true
	bot_spawn_rt.enabled = true

func enable_colors():
	bot_spawn_l.enable_colors()
	bot_spawn_r.enable_colors()
	bot_spawn_lt.enable_colors()
	bot_spawn_rt.enable_colors()

func _fill_range(start: Vector2, end: Vector2, diff = Vector2(1, 1), source = 0):
	for y in range(start.y, end.y + diff.y, diff.y):
		for x in range(start.x, end.x + diff.x, diff.x):
			var coord = Vector2i(x, y)
			var layer = 0
			map.set_cell(layer, coord, source, TILE_ATLAS)
			await _wait(PLACE_TILE_DELAY)
			
#			if connect:
#				map.set_cells_terrain_connect(0, [coord], 0, 0)


func _on_player_left_screen():
	cursor.catch_player(player)


func _on_cursor_catch_finish():
	if not enclosed:
		enclose_player()


func _on_player_double_jumped():
	player.enable_floor_jump()


func _on_flip_toggled():
	player.enable_flip()


func _on_accel_toggled():
	player.enable_accel()


func _on_sfx_toggled():
	player.enable_sound()


func _on_bgm_toggled():
	bgm.playing = true


func _on_freeze_toggled():
	player.enable_freeze()


func _on_shake_toggled():
	player.enable_shake()
