class_name MapCreator
extends TileMap

const PLACE_TILE_DELAY = 0.02

var tile_source = 0
var tile_atlas = Vector2(0, 0)
var terrain_set = 0
var terrain_id = 0
var layer = 0

var enclosed = false

func enclosed_open_top():
	_fill_range(Vector2(-8, -7), Vector2(-8, -7), Vector2(1, 1), -1)
	await _fill_range(Vector2(7, -7), Vector2(7, -7), Vector2(1, 1), -1)
	_update_terrain()

func enclosed_open_bottom():
	_fill_range(Vector2(-14, 5), Vector2(-11, 5), Vector2(1, 1), -1)
	await _fill_range(Vector2(10, 5), Vector2(13, 5), Vector2(1, 1), -1)
	_update_terrain()

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
	
func _fill_range(start: Vector2, end: Vector2, diff = Vector2(1, 1), source = tile_source):
	for y in range(start.y, end.y + diff.y, diff.y):
		for x in range(start.x, end.x + diff.x, diff.x):
			var coord = Vector2i(x, y)
			set_cell(layer, coord, source, tile_atlas)
			await get_tree().create_timer(PLACE_TILE_DELAY).timeout
			
			if GameManager.unlocked_better_graphics() and source != -1:
				set_cells_terrain_connect(layer, [coord], terrain_set, terrain_id)

func _update_terrain():
	if GameManager.unlocked_better_graphics():
		for cell in get_used_cells(layer):
			set_cells_terrain_connect(layer, [cell], terrain_set, terrain_id, false)


func set_tilemap_color():
	if not GameManager.unlocked_better_graphics():
		await create_tween().tween_property(self, "modulate", Color("434343"), 2.0).finished
