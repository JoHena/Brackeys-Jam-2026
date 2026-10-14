extends Node
class_name Movable

@export var highlight: InteractableHighlight = null
@export var body: RigidBody3D = null

@export var move_acceleration: float = 20.0
@export var move_deacceleration: float = 10.0
@export var max_speed: float = 7.0
@export var deacceleration_distance: float = 1.0

var player: Player = null
var is_using: bool = false


func _ready() -> void:
	# Cache the player reference once; warn loudly if it's missing instead
	# of crashing later inside toggle_use().
	player = get_tree().get_first_node_in_group("Player") as Player
	if player == null:
		push_error("%s: no node in group 'Player' found." % name)


## Set/unset follow target
func toggle_movable_use() -> void:
	is_using = not is_using
	player.is_moving_obj = is_using
	
	if is_using:
		body.linear_velocity = Vector3.ZERO
		body.angular_velocity = Vector3.ZERO
		body.gravity_scale = 0.0
	else:
		body.gravity_scale = 1.0


## Handle input to stop interacting or rotate movable object
func _input(event: InputEvent) -> void:
	if not is_using:
		return
	
	# Stop interacting with movable object
	if Input.is_action_just_pressed("Interact") or event.is_action_pressed("ui_cancel"):
		toggle_movable_use()
		get_viewport().set_input_as_handled() # prevent interacting again immediately
		return


## Move towards follow target
func _physics_process(delta) -> void:
	if not is_using: return
	if player.movable_target == null or not is_instance_valid(player.movable_target): return
	
	var direction: Vector3 = player.movable_target.global_position - self.global_position
	var distance = direction.length()
	direction = direction.normalized()
	
	# Stop moving when at target
	if distance < 0.01 and body.linear_velocity.length() < 0.5:
		body.linear_velocity = Vector3.ZERO
		return
	
	var target_speed: float = max_speed
	
	# Slow down as we approach the target.
	if distance < deacceleration_distance:
		target_speed = max_speed * (distance / deacceleration_distance)
	
	var target_velocity: Vector3 = direction * target_speed
	
	body.linear_velocity = body.linear_velocity.move_toward(target_velocity, move_acceleration * delta)


## Setter function for the InteractableHighligt to be enabled/disabled
func set_glow(enabled: bool) -> void:
	highlight.set_highlight(enabled)
