extends Node2D

enum Features {
	ENCLOSE,
	ENEMIES,
	PLATFORMS,
	DIFFICULTY,
	VISUAL,
	SOUND,
	SCORE,
	HEALTH,
}

const PLATFORM_SPAWN_DELAY = 0.5

@onready var platforms := $Platforms

@onready var bot_spawn_l := $BotSpawnerL
@onready var bot_spawn_r := $BotSpawnerR
@onready var bot_spawn_lt := $BotSpawnerL2
@onready var bot_spawn_rt := $BotSpawnerR2

@onready var queue: FeatureQueue = $FeatureQueue
@onready var bgm := $BGM

var map: MapCreator
var player: Player

func _ready():
	queue.add_feature(Features.ENCLOSE, _enclose)
	queue.add_feature(Features.ENEMIES, _enclosed_enemies)
	queue.add_feature(Features.PLATFORMS, _show_platforms)
	queue.add_feature(Features.DIFFICULTY, _spawn_top_enemies)
	queue.add_feature(Features.VISUAL, _better_visuals)
	queue.add_feature(Features.SOUND, _enable_sound)
	queue.add_feature(Features.SCORE, _enable_score)
	queue.add_feature(Features.HEALTH, _enable_health)
	
	queue.enable_feature(Features.ENCLOSE)

func _enclose():
	await DialogManager.show_dialog_wait_sec(tr("ENCLOSE_CREATE"), 1.0)
	await map.enclose_player()
	queue.enable_feature(Features.ENEMIES, 4.0)

func _enclosed_enemies():
	await DialogManager.show_dialog_wait_sec(tr("ENCLOSE_ENEMIES"))
	await map.enclosed_open_bottom()
	bot_spawn_l.enabled = true
	bot_spawn_r.enabled = true
	
	queue.enable_feature(Features.PLATFORMS, 4.0)

func _show_platforms():
	await DialogManager.show_dialog_wait_sec(tr("ENCLOSE_PLATFORMS"))
	for platform in platforms.get_children():
		platform.enable()
		await get_tree().create_timer(PLATFORM_SPAWN_DELAY).timeout
	
	queue.enable_feature(Features.DIFFICULTY, 4.0)

func _spawn_top_enemies():
	await DialogManager.show_dialog_wait_sec(tr("ENCLOSE_DIFFICULTY"))
	await map.enclosed_open_top()
	bot_spawn_lt.enabled = true
	bot_spawn_rt.enabled = true

	queue.enable_feature(Features.VISUAL, 4.0)

func _better_visuals():
	await DialogManager.show_dialog_wait_sec(tr("ENCLOSE_VISUAL"))
	await map.set_tilemap_color()
	bot_spawn_l.enable_visuals()
	bot_spawn_r.enable_visuals()
	bot_spawn_lt.enable_visuals()
	bot_spawn_rt.enable_visuals()
	
	queue.enable_feature(Features.SOUND, 4.0)

func _enable_sound():
	await DialogManager.show_dialog_wait_sec(tr("ENCLOSE_SOUND"))
	bgm.playing = true
	player.enable_sound()
	player.enable_visuals()
	
	queue.enable_feature(Features.SCORE, 4.0)

func _enable_score():
	await DialogManager.show_dialog_wait_sec(tr("ENCLOSE_SCORE"))
	# TODO: make one 100% spawn the first one
	bot_spawn_l.score_spawn_chance = 0.1
	bot_spawn_r.score_spawn_chance = 0.1
	bot_spawn_lt.score_spawn_chance = 0.2
	bot_spawn_rt.score_spawn_chance = 0.2
	
	# TODO: show scores
	queue.enable_feature(Features.HEALTH, 4.0)

func _enable_health():
	await DialogManager.show_dialog_wait_sec(tr("ENCLOSE_HEALTH"))
	player.enable_health()
	# TODO: show health
