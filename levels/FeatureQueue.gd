class_name FeatureQueue
extends Node

var features = []
var delays = {}
var callbacks = {}


func add_feature(feature: int, callback: Callable):
	callbacks[feature] = callback

func enable_feature(feature: int, delay = 0.0):
	features.append(feature)
	delays[feature] = delay

func _process(delta):
	var feature = features.pop_front()
	if feature in callbacks:
		await get_tree().create_timer(delays[feature]).timeout
		await callbacks[feature].call()
