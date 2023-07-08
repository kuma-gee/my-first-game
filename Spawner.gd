extends Marker2D

@export var start_spawn_timer := 2.0
@export var end_spawn_timer := 5.0

@export var enabled := false
@export var flip_dir := false

const ENEMY_SCENE = preload("res://enemy.tscn")

var timer = null
var colors_enabled = false
var effect_enabled = false

func _process(delta):
	if not enabled or timer != null: return
	
	var spawn_timer = randf_range(start_spawn_timer, end_spawn_timer)
	timer = get_tree().create_timer(spawn_timer)
	timer.timeout.connect(func(): _spawn_enemy())

func _spawn_enemy():
	var enem = ENEMY_SCENE.instantiate()
	enem.colors_enabled = colors_enabled
	enem.effect_enabled = effect_enabled
	enem.global_position = global_position
	if flip_dir:
		enem.dir = enem.dir.rotated(PI)
	
	get_tree().current_scene.add_child(enem)
	timer = null

func enable_colors():
	colors_enabled = true
	for enem in get_tree().get_nodes_in_group("enemy"):
		enem.colors_enabled = colors_enabled

func enable_effect():
	effect_enabled = true
	for enem in get_tree().get_nodes_in_group("enemy"):
		enem.effect_enabled = effect_enabled
