extends StaticBody3D
class_name CropSocket

@onready var POS = $"Socket Pos"
@export var CURRENT_CROP : Node3D

func _process(delta):
	if CURRENT_CROP == null:
		return
	
	if randi_range(0, 1000) == 1000:
		CURRENT_CROP.increment_stage()
