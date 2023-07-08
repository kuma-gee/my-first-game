extends Node2D

const PLACE_TILE_DELAY = 0.05
const PLACE_PLAYER_DELAY = 0.5

const PLATFORM_SPAWN_DELAY = 0.5
const PLATFORM_SCENE = preload("res://platform.tscn")

@onready var map := $TileMap
@onready var anim := $AnimationPlayer
@onready var player := $Player
@onready var cursor := $Cursor
@onready var bgm := $BGM
@onready var tilemap := $TileMap

@onready var hp_container := $CanvasLayer2/MarginContainer/HBoxContainer/HPContainer
@onready var score := $CanvasLayer2/MarginContainer/HBoxContainer/Score

@onready var finished_text := $CanvasLayer2/End/CenterContainer2/FinishedText
@onready var restart_text := $CanvasLayer2/End/CenterContainer2/RestartText

@onready var bot_spawn_l := $BotSpawnerL
@onready var bot_spawn_r := $BotSpawnerR
@onready var bot_spawn_lt := $BotSpawnerL2
@onready var bot_spawn_rt := $BotSpawnerR2

var tile_source = 0
var tile_atlas = Vector2(0, 0)
var terrain_set = 0
var terrain_id = 0
var layer = 0

var enclosed = false
var platform_positions = []
var speed_scale = 1.0

func _ready():
	if GameManager.restarts == 3:
		finished_text.text = "I guess you have noticed I'm getting faster\nat building the game. But nothing special about it\nYou can go on with your life."
		restart_text.text = "Well, then here we go again"
	
	if GameManager.restarts == GameManager.RESTARTS_FOR_BETTER_GRAPHICS:
		finished_text.text = "I guess you really like this game.\nYou deserve some better graphics then"
		restart_text.text = "Have fun."
	
	if GameManager.unlocked_better_graphics():
		finished_text.text = "Ready for another round?"
		restart_text.text = "Let's go then"
		tile_source = 2
		tile_atlas = Vector2(2, 0)
	
	speed_scale = min(1.0 + GameManager.restarts, 10)
	anim.speed_scale = speed_scale
	
	score.modulate = Color.TRANSPARENT
	map.clear()
	for child in map.get_children():
		platform_positions.append(child.global_position)
		map.remove_child(child)

func _wait(sec):
	await get_tree().create_timer(sec).timeout

func build_first_platform():
	await _fill_range(Vector2(-10, 6), Vector2(9, 6))
	_update_terrain()
	
	await _wait(PLACE_PLAYER_DELAY / speed_scale)
	anim.play("place_player")

func enclose_player():
	if enclosed: return
	enclosed = true
	
	var lowest_y = 7
	var highest_y = -9
	_fill_range(Vector2(-10, lowest_y - 1), Vector2(9, lowest_y), Vector2(1, 1))
	_fill_range(Vector2(10, lowest_y), Vector2(13, highest_y), Vector2(1, -1))
	await _fill_range(Vector2(-11, lowest_y), Vector2(-14, highest_y), Vector2(-1, -1))
	await _fill_range(Vector2(-11, highest_y + 2), Vector2(10, highest_y), Vector2(1, -1))
	
	_update_terrain()
	if anim.is_playing():
		await anim.animation_finished
	anim.play("platforms")
	
func show_platforms():
	for pos in platform_positions:
		var platform = PLATFORM_SCENE.instantiate()
		platform.global_position = pos
		map.add_child(platform)
		await _wait(PLATFORM_SPAWN_DELAY / speed_scale)
	
	anim.play("enemies")

func spawn_bot_enemies():
	_fill_range(Vector2(-14, 5), Vector2(-11, 5), Vector2(1, 1), -1)
	await _fill_range(Vector2(10, 5), Vector2(13, 5), Vector2(1, 1), -1)
	_update_terrain()
	bot_spawn_l.enabled = true
	bot_spawn_r.enabled = true

func spawn_top_enemies():
	_fill_range(Vector2(-8, -7), Vector2(-8, -7), Vector2(1, 1), -1)
	await _fill_range(Vector2(7, -7), Vector2(7, -7), Vector2(1, 1), -1)
	_update_terrain()
	bot_spawn_lt.enabled = true
	bot_spawn_rt.enabled = true

func set_tilemap_color():
	if not GameManager.unlocked_better_graphics():
		create_tween().tween_property(tilemap, "modulate", Color("434343"), 2.0)

func enable_colors():
	bot_spawn_l.enable_colors()
	bot_spawn_r.enable_colors()
	bot_spawn_lt.enable_colors()
	bot_spawn_rt.enable_colors()

func spawn_scores():
	bot_spawn_l.score_spawn_chance = 0.1
	bot_spawn_r.score_spawn_chance = 0.1
	bot_spawn_lt.score_spawn_chance = 0.2
	bot_spawn_rt.score_spawn_chance = 0.2

func _fill_range(start: Vector2, end: Vector2, diff = Vector2(1, 1), source = tile_source):
	for y in range(start.y, end.y + diff.y, diff.y):
		for x in range(start.x, end.x + diff.x, diff.x):
			var coord = Vector2i(x, y)
			map.set_cell(layer, coord, source, tile_atlas)
			await _wait(PLACE_TILE_DELAY / speed_scale)
			
			if GameManager.unlocked_better_graphics() and source != -1:
				map.set_cells_terrain_connect(layer, [coord], terrain_set, terrain_id)

func _update_terrain():
	if GameManager.unlocked_better_graphics():
		for cell in map.get_used_cells(layer):
			map.set_cells_terrain_connect(layer, [cell], terrain_set, terrain_id, false)

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


func _on_player_lost_health(hp: int):
	for i in range(hp_container.get_child_count()):
		if i < hp:
			continue
		
		var child = hp_container.get_child(i)
		child.lost_hp()

	if hp == 1:
		hp_container.get_child(0).pulse()


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
	GameManager.restarts += 1
	get_tree().reload_current_scene()


func _on_player_score_updated(s: int):
	show_score()
	score.text = "Score: %s" % s

func show_score():
	if score.modulate == Color.TRANSPARENT:
		create_tween().tween_property(score, "modulate", Color.WHITE, 1.0)
