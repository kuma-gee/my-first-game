extends Node2D

const ENCLOSED_LEVEL = preload("res://levels/EnclosedLevel.tscn")

@onready var map: MapCreator = $TileMap
@onready var player := $Player
@onready var cursor := $Cursor
@onready var bgm := $BGM

var fallen = 0

func _ready():
	await DialogManager.show_dialog(tr("INTRO_HELLO"))
	await DialogManager.show_dialog(tr("INTRO_CREATE_GAME"))

func _on_player_left_screen():
	cursor.catch_player(player)
	fallen += 1
	
	if fallen == 3:
		var level = ENCLOSED_LEVEL.instantiate()
		level.map = map
		level.player = player
		add_child(level)


#func _on_player_lost_health(hp: int):
#	for i in range(hp_container.get_child_count()):
#		var child = hp_container.get_child(i)
#		if i < hp:
#			child.heal_hp()
#			continue
#
#		child.lost_hp()
#
#	if hp >= 1:
#		var first = hp_container.get_child(0)
#		if hp == 1:
#			first.pulse()
#		else:
#			first.stop_pulse()

func pause():
	get_tree().paused = true

func restart():
	get_tree().paused = false
	GameManager.restarts += 1
	get_tree().reload_current_scene()

