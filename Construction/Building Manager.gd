extends Node

@export var KEY_BIND_PLACE := "left click"
@export var KEY_BIND_BUILD_START := "build"
@export var KEY_BIND_BUILD_SELECT_WHEEL := "select"

@export var GHOST_FOUNDATION : PackedScene
@export var FOUNDATION : PackedScene
@export var WALL : PackedScene
@export var GHOST_WALL : PackedScene

@export var PLAYER : CharacterBody3D

# Keep track of if we are currenty building, and if we can build
var building = false
var can_place = false

# Ghost copy to indicate placment
var ghost : Node3D
# Construction to place
var construct : Node3D

# Ray cast hit
var hit

# Raycast from the players head
var player_head_raycast : RayCast3D

func _ready():
	# Reference player's head raycast
	player_head_raycast = PLAYER.HEAD.RAYCAST
	# Set the collision mask to look for regular collisions and construction collisions
	player_head_raycast.collision_mask = 1|2
	# Create a copy of ghost foundation and hide it
	ghost = GHOST_FOUNDATION.instantiate()
	ghost.hide()
	# Parent it to the root of the game
	get_window().add_child.call_deferred(ghost)
	$"Building UI".hide()
	# Set default construction to foundation
	construct = FOUNDATION.instantiate()

func _input(event):
	if event.is_action_pressed(KEY_BIND_BUILD_START):
		building = !building
		
	if event.is_action_pressed(KEY_BIND_PLACE) && can_place:
		build()

	# Only open select wheel when we are already building
	if event.is_action_pressed(KEY_BIND_BUILD_SELECT_WHEEL) && building:
		open_wheel()
	
	if event.is_action_released(KEY_BIND_BUILD_SELECT_WHEEL):
		close_wheel()

func _process(delta):
	if building:
		place_ghost()
	else:
		can_place = false
		ghost.hide()

func open_wheel():
	# Show UI
	$"Building UI".show()
	# Show mouse
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
func close_wheel():
	# Hide UI
	$"Building UI".hide()
	# Capture mouse
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func place_ghost():
	# Place a ghost on the floor to see where a construction is placed
	
	# Fire ray cast from head to try and hit a collider
	hit = player_head_raycast.get_collider()
	var pos = player_head_raycast.get_collision_point()
	if hit:
		can_place = check_valid(hit)
		# Show the ghost and move to pos
		ghost.show()
		# Check if the colliding hit is a construction socket
		if hit is Socket:
			ghost.global_position = hit.POS.global_position
			ghost.rotation = hit.POS.global_rotation
		else:
			# Set rotation to the player's rotation
			ghost.rotation = PLAYER.rotation
			ghost.global_position = pos
	else:
		can_place = false
		# Hide the ghost
		ghost.hide()

func check_valid(hit):
	# Check we are placing on a block building
	if hit is BlockBuilding:
		return false
	# Check is we have overlaping bodies, the 'PLACEMENT' has layers for construction
	return !ghost.PLACEMENT.has_overlapping_bodies()

func build():
	# Place construct
	get_window().add_child.call_deferred(construct.duplicate())
	# Copy the position and rotation of the ghost
	construct.position = ghost.global_position 
	construct.rotation = ghost.rotation

func _on_wall_mouse_entered():
	# Set current construction and ghost to wall
	construct = WALL.instantiate()
	
	get_window().remove_child.call_deferred(ghost)	
	ghost = GHOST_WALL.instantiate()
	get_window().add_child.call_deferred(ghost)
	
func _on_foundation_mouse_entered():
	pass
	# Set current  construction and ghost to foundation
	# construct = FOUNDATION.instantiate()
	# ghost = GHOST_FOUNDATION.instantiate()
