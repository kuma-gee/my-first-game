extends Control

var removing = false

func lost_hp():
	removing = true
	var tw = create_tween()
	tw.tween_property(self, "modulate", Color.TRANSPARENT, 0.5)
	tw.parallel().tween_property(self, "position", position + Vector2.UP * 10, 0.5)
	await tw.finished
	
	queue_free()
