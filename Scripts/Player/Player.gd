extends CharacterBody3D

# Seteo de variables generales
@export_category("Player Movement")
@export var speed := 2.0
@export var WALK_SPEED := 1.75
@export var SPRINT_SPEED := 2.5
@export var jump_velocity := 4.5

const ROTATION_SPEED := 10.0
const CAMERA_ROTATION_SPEED := 0.005
const DOUBLE_CLICK_THRESHOLD := 0.25

@onready var text_interact : Label = $CanvasLayer/UI/BoxContainer/TextInteract
@onready var see_cast : ShapeCast3D = $playermodel/Prototype/SeeCast02
@onready var camera_pivot : Node3D = $camera_pivot
@onready var camera_3d: Camera3D = $camera_pivot/SpringArm3D/Camera3D
@onready var playermodel : Node3D = $playermodel
@onready var animation_player : AnimationPlayer = $playermodel/Prototype/Player/AnimationPlayer
@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var map = get_parent().get_node("Map")
@onready var timer: Timer = $Timer
@onready var interact_button: Button = $CanvasLayer/UI/HFlowContainer/InteractButton
@onready var audio_footsteps: AudioStreamPlayer = $AudioFootsteps
@onready var timer_footsteps: Timer = $TimerFootsteps

enum AnimationState {IDLE, WALKING, RUNNING, TALKING}

var player_animation_state : AnimationState = AnimationState.IDLE
var target_positions : Array = []
var target_position : Vector3 = Vector3.ZERO
# var target_rotation : Vector3 = Vector3.ZERO
var moving_to_target : bool = false
var target
var has_target : bool = false
var should_run : bool = false
var interactable_item_list : Array
var last_click_time := 0.0

const PATH_POSITION_CHAIN : bool = false
const CURSOR_POINTER = preload("res://Scenes/UI/cursor_pointer.tscn")

var is_dialogue_active : bool = false
var can_glow_interactables : bool = true
var already_called_clear_interactable_glow : bool = false
var started_audio_footsteps : bool = false

func _ready() -> void:
	# nav_agent.set_target_position(global_transform.origin)
	# print("Agent map: ", NavigationServer3D.agent_get_map(nav_agent.get_rid()))
	process_mode = Node.PROCESS_MODE_ALWAYS
	DialogueManager.dialogue_started.connect(_on_dialogue_start)
	DialogueManager.dialogue_ended.connect(_on_dialogue_end)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("escape"):
		GameManager._toggle_pause()
	
	if event.is_action_pressed("interact") and not is_dialogue_active:
		_clear_movement()
		start_interaction()
	
	if event.is_action_pressed("left_click"): # Input.is_action_pressed("left_click")
		var ui_clicked = get_viewport().gui_get_hovered_control()
		print(ui_clicked)
		if ui_clicked != null and ui_clicked.visible:
			return
		if not PATH_POSITION_CHAIN:
			_clear_movement()
		var camera = get_viewport().get_camera_3d()
		var from = camera.project_ray_origin(get_viewport().get_mouse_position())
		var to = from + camera.project_ray_normal(get_viewport().get_mouse_position()) * 1000
		var space_state = get_world_3d().direct_space_state
		var query = PhysicsRayQueryParameters3D.create(from, to, 1 << 2) # << 2
		query.collide_with_areas = false
		query.collide_with_bodies = true
		# query.collision_mask = 1 << 2
		
		var result = space_state.intersect_ray(query)
		var current_click_time = Time.get_ticks_msec() / 1000.0
		if current_click_time - last_click_time <= DOUBLE_CLICK_THRESHOLD:
			should_run = true
			timer.stop()
		else:
			timer.start(DOUBLE_CLICK_THRESHOLD)
		last_click_time = current_click_time
		
		if result and result.has("position"):
			var new_position = Vector3(result.position.x, 0, result.position.z)
			if PATH_POSITION_CHAIN:
				target_positions.append(new_position)
			else:
				target_position = new_position
			nav_agent.set_target_position(target_position)
			has_target = true
			print("Target position: ", target_position)
		else:
			print("No hit")
	
	if event.is_action_pressed("right_click"):
		_clear_movement()
		# rotación cámara
		if can_glow_interactables:
			can_glow_interactables = false
			interactable_item_list = get_tree().get_nodes_in_group("Interactable")
			if interactable_item_list.size() > 0:
				for item in interactable_item_list:
					if item.has_method("_glow"):
						item.call("_glow", true)

func _clear_interactable_glow() -> void:
	print("Called clear interactable.")
	await get_tree().create_timer(1.5).timeout
	if interactable_item_list.size() > 0:
		for item in interactable_item_list:
			if item.has_method("_glow"):
				item.call("_glow", false)
		interactable_item_list.clear()
	already_called_clear_interactable_glow = false
	can_glow_interactables = true

func _clear_movement() -> void:
	if has_target or moving_to_target:
		target_positions.clear()
		has_target = false
		moving_to_target = false
		target_position = global_position
		nav_agent.set_velocity_forced(Vector3.ZERO)
		nav_agent.set_target_position(global_position)
		nav_agent.get_next_path_position()

func _process(_delta: float) -> void:
	# print("MODEL FORWARD:", playermodel.global_transform.basis.z)
	# print("Player is grunded: ", is_on_floor())
	if not already_called_clear_interactable_glow and not can_glow_interactables:
		already_called_clear_interactable_glow = true
		_clear_interactable_glow()
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
				interact_button.show()
				if target.has_method("_glow") and not target.is_glowing():
					target.call("_glow", true)
		else:
			text_interact.hide()
			interact_button.hide()
			target = null
		
		if not is_on_floor():
			velocity.y += get_gravity().y * delta
			nav_agent.set_velocity_forced(velocity)
		else:
			velocity.y = 0
		
		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = jump_velocity
		
		# Seteo de velocidades si corre o camina
		if should_run:
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
				start_footsteps()
		AnimationState.RUNNING:
			if velocity.length() > 0.01:
				animation_player.play("Run2")
				start_footsteps()
		AnimationState.TALKING:
			stop_footsteps()
			animation_player.play("Talk2")
		AnimationState.IDLE:
			stop_footsteps()
			animation_player.play("IdleStandard")

func start_interaction() -> void:
	if target != null:
		await get_tree().create_timer(0.4).timeout
		target.call("interact")
		text_interact.hide()
		interact_button.hide()

func spawn_move_pointer(new_position : Vector3) -> void:
	var pointer_instance = CURSOR_POINTER.instantiate()
	map.add_child(pointer_instance)
	pointer_instance.global_position = new_position
	pointer_instance.position.y = 0.5

func get_camera_3d() -> Camera3D:
	return camera_3d

# Deprecada, muy tosca la rotación
#func face_interactable(target_pos: Vector3, delta: float) -> void:
	#var pos = target_pos
	#pos.y = global_position.y  # solo rotar en Y
#
	#var dir = pos - global_position
	#if dir.length() < 0.01:
		#return
#
	#var target_y = atan2(dir.x, dir.z)
	#playermodel.rotation.y = lerp_angle(rotation.y, target_y, delta * 8.0)

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
		var next_path_position = nav_agent.get_next_path_position()
		var direction = (next_path_position - global_position).normalized() # global_position.direction_to(next_path_position)
		velocity = direction * speed
		rotate_model(direction, delta)
		moving_to_target = true
	else:
		player_animation_state = AnimationState.IDLE
	
	if nav_agent.is_navigation_finished():
		var direction
		if target != null:
			direction = (target.global_position - global_position).normalized()
		else:
			direction = (target_position - global_position).normalized()
		direction.y = 0
		rotate_model(direction, delta)
		has_target = false
		moving_to_target = false
		should_run = false
		velocity = Vector3.ZERO
		player_animation_state = AnimationState.IDLE
	
func rotate_model(direction: Vector3, delta: float) -> void:
	# print("Rotate to: ", direction)
	if direction != Vector3.ZERO:
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

func _on_interact_button_pressed() -> void:
	start_interaction()

func start_footsteps():
	if player_animation_state == AnimationState.WALKING:
		timer_footsteps.wait_time = 0.6
		audio_footsteps.pitch_scale = randf_range(0.95, 1.05)
	elif player_animation_state == AnimationState.RUNNING:
		timer_footsteps.wait_time = 0.45
		audio_footsteps.pitch_scale = randf_range(0.99, 1.01)
	if not started_audio_footsteps:
		started_audio_footsteps = true
		timer_footsteps.start()
		audio_footsteps.play()

func stop_footsteps():
	started_audio_footsteps = false
	timer_footsteps.stop()
	audio_footsteps.stop()

func play_sound_footsteps() -> void:
	if audio_footsteps.playing:
		audio_footsteps.stop()
	audio_footsteps.play()

func _on_timer_footsteps_timeout() -> void:
	play_sound_footsteps()
