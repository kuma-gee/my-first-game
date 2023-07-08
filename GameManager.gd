extends Node

const RESTARTS_FOR_BETTER_GRAPHICS = 5

var restarts = 5

func unlocked_better_graphics():
	return restarts > RESTARTS_FOR_BETTER_GRAPHICS
