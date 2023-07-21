extends CanvasLayer

signal dialog_finished

@export var label: Label

func show_dialog(text: String):
	label.text = text
	get_tree().create_timer(4.0).timeout.connect(finish_dialog)

func finish_dialog():
	label.text = ""
	dialog_finished.emit()
