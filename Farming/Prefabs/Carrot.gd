extends Node3D

@export var STAGE : int

# Keep track of starting pos when planted (stage = 0)
var start_pos

func increment_stage():
	if STAGE == 10:
		return
	STAGE += 1
	position.y += 0.1

func set_stage(stage : int):
	STAGE = stage
