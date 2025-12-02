extends CharacterBody3D

# Seteo de variables generales
@export_category("Player Movement")
@export var speed := 2.0
@export var WALK_SPEED := 2.0
@export var SPRINT_SPEED := 3.5
@export var jump_velocity := 4.5
const ROTATION_SPEED := 10.0
const CAMERA_ROTATION_SPEED := 0.005

@onready var text_interact : Label = $CanvasLayer/BoxContainer/TextInteract
@onready var see_cast : ShapeCast3D = $playermodel/Prototype/SeeCast02
@onready var camera_pivot : Node3D = $camera_pivot
@onready var playermodel : Node3D = $playermodel
@onready var animation_player : AnimationPlayer = $playermodel/Prototype/Player/AnimationPlayer
@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var map = get_parent().get_node("Map")

enum AnimationState {IDLE, WALKING, RUNNING, TALKING}

var player_animation_state : AnimationState = AnimationState.IDLE
var target_positions : Array = []
var target_position: Vector3 = Vector3.ZERO
var moving_to_target : bool = false
var target
var has_target : bool = false

const CURSOR_POINTER = preload("res://Scenes/UI/cursor_pointer.tscn")

var is_dialogue_active : bool = false

func _ready() -> void:
	# nav_agent.set_target_position(global_transform.origin)
	process_mode = Node.PROCESS_MODE_ALWAYS
	DialogueManager.dialogue_started.connect(_on_dialogue_start)
	DialogueManager.dialogue_ended.connect(_on_dialogue_end)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("escape"):
		GameManager._toggle_pause()
	
	if event.is_action_pressed("left_click"): # Input.is_action_pressed("left_click")
		var camera = get_viewport().get_camera_3d()
		var from = camera.project_ray_origin(get_viewport().get_mouse_position())
		var to = from + camera.project_ray_normal(get_viewport().get_mouse_position()) * 1000

		var space_state = get_world_3d().direct_space_state
		var query = PhysicsRayQueryParameters3D.create(from, to, 1 << 2)
		query.collide_with_areas = false
		query.collide_with_bodies = true
		# query.collision_mask = 1 << 2
		
		var result = space_state.intersect_ray(query)
		
		if result and result.has("position"):
			target_positions.append(Vector3(result.position.x, 0, result.position.z)) 
			nav_agent.set_target_position(target_position)
			has_target = true
			
		else:
			print("No hit")
			
	if event.is_action_pressed("right_click"):
		_clear_movement()

func _clear_movement() -> void:
	target_positions.clear()
	has_target = false
	moving_to_target = false
	velocity = Vector3.ZERO
	nav_agent.target_position = global_position
	nav_agent.set_velocity_forced(Vector3.ZERO)

func _process(_delta: float) -> void:
	# print("MODEL FORWARD:", playermodel.global_transform.basis.z)
	pass

func _physics_process(delta: float) -> void:
	if GameManager._is_game_paused():
		animation_player.stop(true)
		return
	
	if target_positions.size() > 0:
		if not has_target and not moving_to_target:
			print("Next targets: ", target_positions)
			target_position = target_positions.front()
			target_positions.remove_at(0)
			print("Setting target: ", target_position)
			print("Remain targets: ", target_positions)
			has_target = true
			
	
	if is_dialogue_active:
		player_animation_state = AnimationState.TALKING
	else:
		# print("Collision count: ", see_cast.get_collision_count())
		if see_cast.is_colliding() and see_cast.get_collision_count() > 0:
			target = see_cast.get_collider(0)
			if target and target.has_method("interact"):
				text_interact.show()
				face_interactable(target.position, delta)
				if target.has_method("glow"):
					target.call("glow", true)
				if Input.is_action_just_pressed("interact") and not is_dialogue_active:
					target.call("interact")
					text_interact.hide()
		else:
			text_interact.hide()
			if target and target.has_method("glow"):
				target.call("glow", false)
		
		if not is_on_floor():
			velocity.y += get_gravity().y * delta
		else:
			velocity.y = 0
		
		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = jump_velocity
		
		# Seteo de velocidades si corre o camina
		if Input.is_action_pressed("sprint"):
			speed = SPRINT_SPEED
		else:
			speed = WALK_SPEED
		
		if has_target or moving_to_target:
			if speed > WALK_SPEED:
				player_animation_state = AnimationState.RUNNING
			else:
				player_animation_state = AnimationState.WALKING
		else:
			player_animation_state = AnimationState.IDLE
			
		
		# move_type1(delta)
		move_type2(delta)
		
	move_and_slide()
		
	match player_animation_state:
		AnimationState.WALKING:
			if velocity.length() > 0.01:
				animation_player.play("Walk")
		AnimationState.RUNNING:
			if velocity.length() > 0.01:
				animation_player.play("Run2")
		AnimationState.TALKING:
			animation_player.play("Talk2")
		AnimationState.IDLE:
			animation_player.play("IdleStandard")

func spawn_move_pointer(new_position : Vector3) -> void:
	var pointer_instance = CURSOR_POINTER.instantiate()
	map.add_child(pointer_instance)
	pointer_instance.global_position = new_position
	pointer_instance.position.y = 0.5

func face_interactable(facing_position : Vector3, delta) -> void:
	var direction = (facing_position - global_position).project(Vector3(1,0,1)).normalized()
	rotate_model(direction, delta)


func move_type1(delta: float) -> void:
	if has_target:
		var dir = target_position - global_position
		dir.y = 0
		var distance = dir.length()
		
		if distance > 0.25:
			dir = dir.normalized()
			velocity.x = dir.x * speed
			velocity.z = dir.z * speed
			moving_to_target = true
			rotate_model(dir, delta)
		else:
			moving_to_target = false
			velocity.x = move_toward(velocity.x, 0, speed)
			velocity.z = move_toward(velocity.z, 0, speed)
			player_animation_state = AnimationState.IDLE
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
		player_animation_state = AnimationState.IDLE

	#if not is_on_floor():
		#player_animation_state = AnimationState.JUMPING

func move_type2(delta : float) -> void:

	if has_target:
		if not moving_to_target:
			spawn_move_pointer(target_position)
		nav_agent.set_target_position(target_position)
		var next = nav_agent.get_next_path_position()
		var direction = (next - global_transform.origin).normalized()
		velocity = direction * speed
		rotate_model(direction, delta)
		moving_to_target = true
	else:
		player_animation_state = AnimationState.IDLE
	
	if nav_agent.is_navigation_finished():
		has_target = false
		moving_to_target = false
		velocity = Vector3.ZERO
		player_animation_state = AnimationState.IDLE
	
func rotate_model(direction: Vector3, delta: float) -> void:
	var target_basis = Basis.looking_at(direction)
	playermodel.basis = playermodel.basis.slerp(target_basis, ROTATION_SPEED * delta)

func _on_dialogue_start(_dialogue) -> void:
	is_dialogue_active = true

func _on_dialogue_end(_dialogue) -> void:
	await get_tree().create_timer(0.2).timeout
	is_dialogue_active = false

func _reset_movement_state() -> void:
	target_position = global_position
	moving_to_target = false

## ================= Comienzo debug CFG ================= #
## Property directly below #@Debug will be monitored
##@Debug
#var property_1:int = 300
#
## function too.
## Note that _process is called every frame.
##@Debug
#func get_str():
	#return "abc"
##@Debug'alias_name'
#var property_2:String = ""
##@Debug(category_name)
#var property_3:Vector2 = Vector2.ZERO
##@Debug(cate1/nested_category2)
#var property_4:Vector3 = Vector3.ZERO
##---
## specify properties by property name
##@Debug[position]
##---
## another node's properyy by property name.
## However, it can only be monitored and cannot be edited.
##@Debug[./ChildNode:position]
## Internally, get_node() is used up to the : character, 
## so % can also be used.
##@Debug[%ChildNode:position]
##---
## You can assign colors for better readability using {}.
##@Debug{#RED}
#var property_5:StringName = &""
##@Debug{#f0f0f0}
#var property_6:bool = false
##---
## Multiple settings
##@Debug(cate)'alias'{#RED}
#var property_7:int = 123
##@Debug{#f0f0f0}
#var property_8:bool = false
## ================= Fin debug CFG ================= #

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
