extends CanvasLayer

signal dialog_finished

@export var label: Label

@onready var finish_timer := $FinishTimer

func show_dialog(text: String):
	label.text = text
	finish_timer.start()
	await dialog_finished

func show_dialog_wait_sec(text: String, sec = 2.0):
	show_dialog(text)
	await get_tree().create_timer(sec).timeout

func _on_finish_timer_timeout():
	label.text = ""
	dialog_finished.emit()
