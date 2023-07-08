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
@onready var hp_container := $CanvasLayer2/MarginContainer/HPContainer

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
	enclosed = true
	
	var lowest_y = 7
	var highest_y = -9
	_fill_range(Vector2(-10, lowest_y - 1), Vector2(9, lowest_y), Vector2(1, 1))
	_fill_range(Vector2(10, lowest_y), Vector2(12, highest_y), Vector2(1, -1))
	await _fill_range(Vector2(-11, lowest_y), Vector2(-13, highest_y), Vector2(-1, -1))
	await _fill_range(Vector2(-11, highest_y + 2), Vector2(10, highest_y), Vector2(1, -1))
	
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


func _on_effects_toggled():
	player.enable_effects()
	bot_spawn_l.enable_effect()
	bot_spawn_r.enable_effect()
	bot_spawn_lt.enable_effect()
	bot_spawn_rt.enable_effect()


func _on_player_lost_health():
	if hp_container.get_child_count() > 0:
		var idx = 1
		var hp = hp_container.get_child(hp_container.get_child_count() - idx)
		while hp.removing:
			idx += 1
			var child_index = hp_container.get_child_count() - idx
			if child_index < 0:
				break
			hp_container.get_child(child_index)
		
		if hp and not hp.removing:
			hp.lost_hp()


func _on_player_died():
	if hp_container.get_child_count() > 0:
		for child in hp_container.get_children():
			child.lost_hp()
	anim.play("end")

func pause():
	get_tree().paused = true

func _on_enclose_timer_timeout():
	enclose_player()

func restart():
	get_tree().paused = false
	get_tree().reload_current_scene()
