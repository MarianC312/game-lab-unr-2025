extends CharacterBody3D

@export_category("Player Movement")
@export var speed := 3.0
@export var WALK_SPEED := 3.0
@export var SPRINT_SPEED := 4.5
@export var jump_velocity := 4.5
const ROTATION_SPEED := 10.0

@onready var text_interact : Label = $CanvasLayer/BoxContainer/TextInteract
@onready var see_cast : RayCast3D = $"playermodel/character-male-e2/SeeCast"
@onready var camera_pivot : Node3D = $camera_pivot
@onready var playermodel : Node3D = $playermodel
@onready var animation_player : AnimationPlayer = $"playermodel/character-male-e2/AnimationPlayer"

enum AnimationState {IDLE, RUNNING, JUMPING}
var player_animation_state : AnimationState = AnimationState.IDLE

var target_position: Vector3 = Vector3.ZERO
var moving_to_target := false

func _physics_process(delta: float) -> void:
	
	if see_cast.is_colliding():
		var target = see_cast.get_collider()
		if target.has_method("interact"):
			text_interact.show()
			if Input.is_action_just_pressed("interact"):
				target.call("interact")
	else:
		text_interact.hide()
		
	
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	if Input.is_action_pressed("sprint"):
		speed = SPRINT_SPEED
	else:
		speed = WALK_SPEED

	# --- Detectar clic en el piso ---
	if Input.is_action_pressed("left_click"):
		var camera = get_viewport().get_camera_3d()
		var from = camera.project_ray_origin(get_viewport().get_mouse_position())
		var to = from + camera.project_ray_normal(get_viewport().get_mouse_position()) * 1000

		var space_state = get_world_3d().direct_space_state
		var query = PhysicsRayQueryParameters3D.create(from, to)
		query.collide_with_areas = false
		query.collide_with_bodies = true
		query.collision_mask = 1

		var result = space_state.intersect_ray(query)

		if result and result.has("position"):
			target_position = result.position
			moving_to_target = true
	else:
		moving_to_target = false

	if moving_to_target:
		var dir = target_position - global_position
		dir.y = 0
		var distance = dir.length()

		if distance > 0.1:
			dir = dir.normalized()
			velocity.x = dir.x * speed
			velocity.z = dir.z * speed
			rotate_model(dir, delta)
			player_animation_state = AnimationState.RUNNING
		else:
			moving_to_target = false
			velocity.x = move_toward(velocity.x, 0, speed)
			velocity.z = move_toward(velocity.z, 0, speed)
			player_animation_state = AnimationState.IDLE
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
		player_animation_state = AnimationState.IDLE

	if not is_on_floor():
		player_animation_state = AnimationState.JUMPING

	move_and_slide()

	match player_animation_state:
		AnimationState.IDLE:
			animation_player.play("idle")
		AnimationState.RUNNING:
			animation_player.play("sprint")
		AnimationState.JUMPING:
			animation_player.play("jump")

func rotate_model(direction: Vector3, delta: float) -> void:
	var target_basis = Basis.looking_at(direction)
	playermodel.basis = playermodel.basis.slerp(target_basis, ROTATION_SPEED * delta)




#extends CharacterBody3D
#
#@export_category("Player Movement")
#@export var speed := 3
#@export var WALK_SPEED := speed
#@export var SPRINT_SPEED := speed * 1.5
#@export var jump_velocity := 4.5
#const ROTATION_SPEED := 4.0
#
##slowly rotate the charcter to point in the direction of the camera_pivot
#@onready var camera_pivot : Node3D = $camera_pivot
#@onready var playermodel : Node3D = $playermodel
#
#enum animation_state {IDLE,RUNNING,JUMPING}
#var player_animation_state : animation_state = animation_state.IDLE
#@onready var animation_player : AnimationPlayer = $"playermodel/character-male-e2/AnimationPlayer"
#
#func _physics_process(delta: float) -> void:
	## Add the gravity.
	#if not is_on_floor():
		#velocity += get_gravity() * delta
#
	## Handle jump.
	#if Input.is_action_just_pressed("jump") and is_on_floor():
		#velocity.y = jump_velocity
		##player_animation_state = animation_state.JUMPING
		#
		#
	## Handle Sprint #
	#if Input.is_action_pressed("sprint"):
		#speed = SPRINT_SPEED
	#else:
		#speed = WALK_SPEED
#
	## Get the input direction and handle the movement/deceleration.
	## As good practice, you should replace UI actions with custom gameplay actions.
#
	#var input_dir := Input.get_vector("leftward", "rightward", "forward", "backward")
	#var direction = (camera_pivot.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	#if Input.is_action_just_pressed("left_click"):
		#direction = (camera_pivot.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	#
	#if direction:
		#velocity.x = direction.x * speed
		#velocity.z = direction.z * speed
		##now rotate the model
		#rotate_model(Vector3(direction.x, 0, direction.z), delta)
		#player_animation_state = animation_state.RUNNING
	#else:
		#velocity.x = move_toward(velocity.x, 0, speed)
		#velocity.z = move_toward(velocity.z, 0, speed)
		#player_animation_state = animation_state.IDLE
	#
	#if not is_on_floor():
		#player_animation_state = animation_state.JUMPING
	#
	#move_and_slide()
	##tell the playeranimationcontroller about the animation state
	#match player_animation_state:
		#animation_state.IDLE:
			#animation_player.play("idle")
		#animation_state.RUNNING:
			#animation_player.play("sprint")
		#animation_state.JUMPING:
			#animation_player.play("jump")
#
	#
#func rotate_model(direction: Vector3, delta : float) -> void:
	##rotate the model to match the springarm
	#playermodel.basis = lerp(playermodel.basis, Basis.looking_at(direction), 10.0 * delta)
