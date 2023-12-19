extends Node

@export var KEY_BIND_PLACE := "left click"
@export var KEY_BIND_FARM_START := "farm"
@export var KEY_BIND_FARM_SELECT_WHEEL := "select"

@export var GHOST_CARROT : PackedScene
@export var CARROT : PackedScene

@export var PLAYER : CharacterBody3D

# Keep track of if we are currenty farming, and if we can build
var farming = false
var can_place = false

# Ghost copy to indicate placment
var ghost : Node3D
# Construction to place
var crop : Node3D
# Socket to attach crop to, socket will manage cropgrowing
var socket : Node3D

# Ray cast hit
var hit

# Raycast from the players head
var player_head_raycast : RayCast3D

func _ready():
	# Reference player's head raycast
	player_head_raycast = PLAYER.HEAD.RAYCAST
	# Create a copy of ghost carrot and hide it
	ghost = GHOST_CARROT.instantiate()
	ghost.hide()
	# Parent it to the root of the game
	get_window().add_child.call_deferred(ghost)
	$"Farming UI".hide()
	# Set default crop to carrot
	crop = CARROT.instantiate()

func _input(event):
	if event.is_action_pressed(KEY_BIND_FARM_START):
		farming = !farming
		
	if event.is_action_pressed(KEY_BIND_PLACE) && can_place:
		farm()

	# Only open select wheel when we are already building
	if event.is_action_pressed(KEY_BIND_FARM_SELECT_WHEEL) && farming:
		open_wheel()
	
	if event.is_action_released(KEY_BIND_FARM_SELECT_WHEEL):
		close_wheel()

func _process(delta):
	if farming:
		# Display debug on player UI
		PLAYER.UI.MODE_FARM.text = "farming: True"
		# Set the collision mask to look for farming collisions
		player_head_raycast.set_collision_mask_value(1, false)
		player_head_raycast.set_collision_mask_value(2, false)
		player_head_raycast.set_collision_mask_value(4, true)
		place_ghost()
	else:
		PLAYER.UI.MODE_FARM.text = "farming: False"
		can_place = false
		ghost.hide()

func open_wheel():
	# Show UI
	$"Farming UI".show()
	# Show mouse
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
func close_wheel():
	# Hide UI
	$"Farming UI".hide()
	# Capture mouse
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func place_ghost():
	
	# Fire ray cast from head to try and hit a collider
	hit = player_head_raycast.get_collider()
	var pos = player_head_raycast.get_collision_point()
	# Make sure hitting a CropSocket
	if hit && hit is CropSocket:
		socket = hit
		can_place = true
		# Show the ghost and move snap to socket POS
		ghost.show()
		ghost.global_position = hit.POS.global_position
		ghost.rotation = hit.POS.global_rotation
	else:
		can_place = false
		# Hide the ghost
		ghost.hide()

func farm():
	# Place construct
	var crop_duplicate = crop.duplicate()
	get_window().add_child.call_deferred(crop_duplicate)
	# Copy the position and rotation of the ghost
	crop_duplicate.position = ghost.global_position 
	crop_duplicate.rotation = ghost.rotation
	
		# Set plant stage to 0
	crop_duplicate.set_stage(0)
	
	# Tell socket what crop is being placed
	socket.CURRENT_CROP = crop_duplicate
