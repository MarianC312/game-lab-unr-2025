extends CharacterBody3D

# Seteo de variables generales
@export_category("Player Movement")
@export var speed := 2.0
@export var WALK_SPEED := 1.75
@export var SPRINT_SPEED := 2.5
@export var jump_velocity := 4.5
@export var max_neck_yaw := deg_to_rad(30)
@export var max_head_yaw := deg_to_rad(10)
@export var look_speed := 2.0
@export var spine_turn_threshold := deg_to_rad(5)
@export var spine_turn_speed := 2.0
@export var max_spine_yaw := deg_to_rad(5)
@export var yaw_transfer_speed := 6.0
@onready var spring_arm: SpringArm3D = $camera_pivot/SpringArm3D

@export_category("Camera Avoidance")
@export var spring_length: float = 6.0
@export var camera_rotation_speed: float = 5.0
var camera_target_index: int = 0
var camera_is_avoiding: bool = false
# Variables de camera avoidance - reemplazá las anteriores
var camera_base_y: float = 0.0
var camera_current_y: float = 0.0
var camera_target_y: float = 0.0
var camera_current_index: int = 0
var camera_positions: Array[float] = []
var last_player_position: Vector3 = Vector3.ZERO
var camera_avoid_cooldown: float = 0.0
var camera_is_displaced: bool = false  # true = estamos en una posición que no es la original

const ROTATION_SPEED := 10.0
const CAMERA_ROTATION_SPEED := 0.005
const DOUBLE_CLICK_THRESHOLD := 0.25
const PATH_POSITION_CHAIN : bool = false
const ANIMATION_BLEND_TIME := 0.15
const CURSOR_POINTER = preload("res://Scenes/UI/cursor_pointer.tscn")
const HOVER = preload("res://Sounds/SFX/UI/Seleccionar y hover/Hover.ogg")
const CONTINUAR_HACHAZO_2 = preload("res://Sounds/SFX/UI/Seleccionar menu/Continuar hachazo 2.ogg")
const SELECCIONAR_OPCIONES = preload("res://Sounds/SFX/UI/Seleccionar y hover/Seleccionar opciones.ogg")

@export var first_dialogue : DialogueResource = preload("res://Dialogues/Scene/Prototype01/PlayerFirstDialogue.dialogue")
@export var prototype03_dialogue : DialogueResource = preload("res://Dialogues/Scene/Prototype03/Prototype03.dialogue")
@onready var text_interact : Label = $CanvasLayer5/UI/TextInteract
@onready var see_cast : ShapeCast3D = $playermodel/Prototype/SeeCast02
@onready var camera_pivot : Node3D = $camera_pivot
@onready var camera_3d: Camera3D = $camera_pivot/SpringArm3D/Camera3D
@onready var playermodel : Node3D = $playermodel
@onready var animation_player : AnimationPlayer = $playermodel/Prototype/Player/AnimationPlayer
@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var map = get_parent().get_node("Map")
@onready var timer: Timer = $Timer
@onready var interact_button: Button = $CanvasLayer5/UI/HFlowContainer/InteractButton
@onready var audio_footsteps: AudioStreamPlayer = $AudioFootsteps
@onready var timer_footsteps: Timer = $TimerFootsteps
@onready var journal_button: Button = $CanvasLayer5/UI/HFlowContainer/JournalButton
@onready var skeleton: Skeleton3D = $playermodel/Prototype/Player/Armature/Skeleton3D
@onready var gpu_particles_3d: GPUParticles3D = $playermodel/GPUParticles3D
@onready var sfx_stream_player: AudioStreamPlayer = $SFXStreamPlayer
const COFRE_ABRIR = preload("res://Sounds/SFX/Cofre/Cofre Abrir.ogg")
const COFRE_CERRAR = preload("res://Sounds/SFX/Cofre/Cofre cerrar.ogg")
const DESTRABAR_CERRADURA_2 = preload("res://Sounds/SFX/Cofre/Destrabar cerradura 2.ogg")
const DESTRABAR_CERRADURA = preload("res://Sounds/SFX/Cofre/Destrabar cerradura.ogg")

enum AnimationState {IDLE, WALKING, RUNNING, TALKING, YAWN}

var player_animation_state : AnimationState = AnimationState.IDLE
var _previous_animation_state: AnimationState = AnimationState.IDLE
var target_positions : Array = []
var target_position : Vector3 = Vector3.ZERO
# var target_rotation : Vector3 = Vector3.ZERO
var moving_to_target : bool = false
var target
var has_target : bool = false
var should_run : bool = false
var interactable_item_list : Array
var last_click_time := 0.0
var neck_bone := -1
var head_bone := -1
var spine_bone_1 := -1
var spine_bone_2 := -1
var spine_bone_3 := -1
var current_look_yaw := 0.0
var spine_yaw := 0.0
var look_enabled := true
var is_first_dialogue_done : bool = false # default: false
var is_dialogue_active : bool = false
var is_journal_active : bool = false
var is_pause_active : bool = false
var can_glow_interactables : bool = true
var already_called_clear_interactable_glow : bool = false
var started_audio_footsteps : bool = false
var highlight_tween: Tween
var pending_interactable = null
var hovered_interactable = null

func _ready() -> void:
	# nav_agent.set_target_position(global_transform.origin)
	# print("Agent map: ", NavigationServer3D.agent_get_map(nav_agent.get_rid()))
	process_mode = Node.PROCESS_MODE_ALWAYS
	DialogueManager.dialogue_started.connect(_on_dialogue_start)
	DialogueManager.dialogue_ended.connect(_on_dialogue_end)
	DialogueManager.got_dialogue.connect(_on_dialogue_line)
	SceneManagerMap01.registered_interaction.connect(_on_registered_interaction)
	neck_bone = skeleton.find_bone("mixamorig_Neck")
	head_bone = skeleton.find_bone("mixamorig_Head")
	spine_bone_1 = skeleton.find_bone("mixamorig_Spine")
	spine_bone_2 = skeleton.find_bone("mixamorig_Spine1")
	spine_bone_3 = skeleton.find_bone("mixamorig_Spine2")
	
	camera_base_y = camera_pivot.rotation_degrees.y
	camera_current_y = camera_base_y
	camera_target_y = camera_base_y
	camera_positions = [
		camera_base_y,
		camera_base_y + 90.0,
		camera_base_y + 180.0,
		camera_base_y + 270.0,
	]
	camera_current_index = 0
	spring_arm.spring_length = spring_length
	last_player_position = global_position

func _input(event: InputEvent) -> void:
	#if event.is_action_pressed("pause"):
		#_toogle_pause()
	
	#if event.is_action_pressed("journal"):
		#_toogle_journal()
	
	#if event.is_action_pressed("interact") and not is_dialogue_active:
		#_clear_movement()
		#start_interaction()
	
	if event.is_action_pressed("left_click"): # Input.is_action_pressed("left_click")
		_handle_click()
	
	if event.is_action_pressed("right_click"):
		_clear_movement()
		# rotación cámara
		if can_glow_interactables:
			can_glow_interactables = false
			interactable_item_list = get_tree().get_nodes_in_group("Interactable")
			if interactable_item_list.size() > 0:
				for interactable in interactable_item_list:
					if interactable.has_method("_glow"):
						interactable.call("_glow", true)
					elif interactable.has_method("_glow"):
						interactable.call("_glow", true)

func _handle_click() -> void:
	var ui_clicked = get_viewport().gui_get_hovered_control()
	if ui_clicked != null and ui_clicked.visible:
		return
	if not PATH_POSITION_CHAIN:
		_clear_movement()
	var camera = get_viewport().get_camera_3d()
	var from = camera.project_ray_origin(get_viewport().get_mouse_position())
	var to = from + camera.project_ray_normal(get_viewport().get_mouse_position()) * 1000
	var space_state = get_world_3d().direct_space_state

	# --- Primero: chequeamos objetos interactuables (capa 4) ---
	var query_interact = PhysicsRayQueryParameters3D.create(from, to, 1 << 3)
	query_interact.collide_with_areas = true
	query_interact.collide_with_bodies = true
	var result_interact = space_state.intersect_ray(query_interact)

	# --- Segundo: chequeamos el piso (capa 3) ---
	var query_floor = PhysicsRayQueryParameters3D.create(from, to, 1 << 2)
	query_floor.collide_with_areas = false
	query_floor.collide_with_bodies = true
	var result_floor = space_state.intersect_ray(query_floor)

	# Solo procesamos el interactuable si está MÁS CERCA que el piso
	var interactable_is_closest = false
	if result_interact and result_interact.has("collider"):
		if result_floor and result_floor.has("position"):
			var dist_interact = from.distance_to(result_interact.position)
			var dist_floor = from.distance_to(result_floor.position)
			interactable_is_closest = dist_interact <= dist_floor
		else:
			interactable_is_closest = true

	if interactable_is_closest:
		var collider = result_interact.collider
		if collider.has_method("interact"):
			var distance = global_position.distance_to(collider.global_position)
			if distance <= 1.0:
				collider.interact()
				return
			else:
				target_position = Vector3(result_interact.position.x, 0, result_interact.position.z)
				nav_agent.set_target_position(target_position)
				has_target = true
				pending_interactable = collider
				return

	var query = PhysicsRayQueryParameters3D.create(from, to, 1 << 2)
	query.collide_with_areas = false
	query.collide_with_bodies = true

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
		pending_interactable = null  # cancelamos intención anterior
		if PATH_POSITION_CHAIN:
			target_positions.append(new_position)
		else:
			target_position = new_position
		nav_agent.set_target_position(target_position)
		has_target = true
	else:
		print("No hit")

func get_mouse_dir() -> Vector3:
	var cam := get_viewport().get_camera_3d()
	if cam == null:
		return Vector3.ZERO
	
	var mouse_pos = get_viewport().get_mouse_position()
	
	var origin = cam.project_ray_origin(mouse_pos)
	var dir = cam.project_ray_normal(mouse_pos)
	
	var plane = Plane(
		-cam.global_transform.basis.z,
		global_position
	)

	var hit = plane.intersects_ray(origin, dir)
	if hit == null:
		return Vector3.ZERO
	
	return (hit - global_position).normalized()

func apply_bone_yaw(bone_idx: int, yaw: float):
	if bone_idx == -1:
		return
	
	var pose := skeleton.get_bone_global_pose(bone_idx)
	
	var pos := pose.origin
	var rot := Basis(Vector3.UP, yaw)
	pose.basis = rot * pose.basis
	pose.origin = pos
	
	skeleton.set_bone_global_pose_override(
		bone_idx,
		pose,
		1.0,
		true
	)

func _clear_interactable_glow() -> void:
	print("Called clear interactable.")
	await get_tree().create_timer(3.505).timeout
	#if interactable_item_list.size() > 0:
		#for item in interactable_item_list:
			#if item.has_method("_glow"):
				#item.call("_glow", false)
		#interactable_item_list.clear()
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

func _process(delta: float) -> void:
	update_look(delta)
	update_spine(delta)
	_handle_hover()
	#if Input.is_action_pressed("left_click"):
		#_handle_click()
	# print("MODEL FORWARD:", playermodel.global_transform.basis.z)
	# print("Player is grunded: ", is_on_floor())
	if not already_called_clear_interactable_glow and not can_glow_interactables:
		already_called_clear_interactable_glow = true
		_clear_interactable_glow()
	
	if not journal_button.visible and GameManager.has_journal():
		journal_button.show()
		highlight_button(journal_button)
	_update_camera_avoidance(delta)

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
	
	if is_dialogue_active and is_first_dialogue_done:
		set_animation_state(AnimationState.TALKING)
		if look_enabled:
			disable_look()
	else:
		if not look_enabled:
			enable_look()
		# print("Collision count: ", see_cast.get_collision_count())
		if see_cast.is_colliding() and see_cast.get_collision_count() > 0:
			target = see_cast.get_collider(0)
			# print(target)
			if target and target.has_method("interact"):
				if not text_interact.visible or not interact_button.visible:
					var tgpos = target.global_position
					text_interact.position = camera_3d.unproject_position(tgpos)
					text_interact.show()
					interact_button.show()
					highlight_button(interact_button)
				if target.has_method("_glow") and not target.is_glowing():
					target.call("_glow", true)
		else:
			# stop_highlight(interact_button)
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
				set_animation_state(AnimationState.RUNNING)
			else:
				set_animation_state(AnimationState.WALKING)
		else:
			if player_animation_state not in [AnimationState.YAWN, AnimationState.TALKING, AnimationState.IDLE]:
				animation_player.stop()
				set_animation_state(AnimationState.IDLE)
		
		# move_type1(delta)
		move_type2(delta)
		move_and_slide()
	
	match player_animation_state:
		AnimationState.WALKING:
			start_footsteps()
			if not animation_player.is_playing():
				animation_player.play("Walk")
			if velocity.length() <= 0.01:
				set_animation_state(AnimationState.IDLE)
		AnimationState.RUNNING:
			start_footsteps()
			if not animation_player.is_playing():
				animation_player.play("Run2")
			if velocity.length() <= 0.01:
				set_animation_state(AnimationState.IDLE)
		AnimationState.TALKING:
			stop_footsteps()
			if not is_dialogue_active:
				set_animation_state(AnimationState.IDLE)
			elif not animation_player.is_playing():
				var talk_anims = ["Talk1", "Talk2", "Talk3", "Talk4"]
				animation_player.play(talk_anims.pick_random())
		AnimationState.IDLE:
			stop_footsteps()
			if not animation_player.is_playing():
				var idle_anims = ["IdleStandard", "IdleNeutral"]
				animation_player.play(idle_anims.pick_random())
		AnimationState.YAWN:
			stop_footsteps()
			if not animation_player.is_playing():
				set_animation_state(AnimationState.IDLE)

func set_animation_state(new_state: AnimationState) -> void:
	if new_state == player_animation_state:
		return  # No hacer nada si el estado no cambió
	
	# print(AnimationState)
	# print("Cambiando estado de animación ", player_animation_state, " por ", new_state)
	
	player_animation_state = new_state

	match new_state:
		AnimationState.WALKING:
			animation_player.play("Walk", ANIMATION_BLEND_TIME)
		AnimationState.RUNNING:
			animation_player.play("Run2", ANIMATION_BLEND_TIME)
		AnimationState.TALKING:
			var talk_anims = ["Talk1", "Talk2", "Talk3", "Talk4"]
			animation_player.play(talk_anims.pick_random(), ANIMATION_BLEND_TIME)
		AnimationState.IDLE:
			var idle_anims = ["IdleStandard", "IdleNeutral"]
			animation_player.play(idle_anims.pick_random(), ANIMATION_BLEND_TIME)
		AnimationState.YAWN:
			animation_player.play("Yawn/mixamo_com", ANIMATION_BLEND_TIME)
			animation_player.seek(2.5)

func update_look(delta : float) -> void:
	if look_enabled:
		skeleton.clear_bones_global_pose_override()
		
		var dir = get_mouse_dir()
		# print(dir)
		if dir == Vector3.ZERO:
			return
		
		var local_dir = playermodel.global_transform.basis.inverse() * dir * -1
		#if local_dir.z < 0.0:
			#current_look_yaw = lerp_angle(
				#current_look_yaw,
				#0.0,
				#look_speed * 0.25 * delta
			#)
			#return
		var delta_yaw = atan2(local_dir.x, local_dir.z)
		# print(delta_yaw)
		current_look_yaw = clamp(
			lerp_angle(
				current_look_yaw,
				delta_yaw,
				look_speed * delta
			),
			deg_to_rad(-40),
			deg_to_rad(40)
		)
		
		var neck_yaw = clamp(current_look_yaw * 0.7, deg_to_rad(-25), deg_to_rad(25))
		var head_yaw = clamp(current_look_yaw * 0.3, deg_to_rad(-15), deg_to_rad(15))
		
		apply_bone_yaw(neck_bone, neck_yaw)
		apply_bone_yaw(head_bone, head_yaw)

func update_spine(delta):
	if look_enabled:
		var abs_yaw = abs(current_look_yaw)

		if abs_yaw <= spine_turn_threshold:
			reset_spine(delta, spine_bone_1)
			reset_spine(delta, spine_bone_2)
			reset_spine(delta, spine_bone_3)
			return
		
		var spine_target = clamp(
			current_look_yaw * 0.4,
			-max_spine_yaw,
			max_spine_yaw
		)
		
		spine_yaw = lerp_angle(
			spine_yaw,
			spine_target,
			spine_turn_speed * delta
		)
		
		apply_bone_yaw(spine_bone_1, spine_yaw)
		apply_bone_yaw(spine_bone_2, spine_yaw)
		apply_bone_yaw(spine_bone_3, spine_yaw)

		# Compensar cabeza (clave)
		current_look_yaw = lerp_angle(
			current_look_yaw,
			current_look_yaw - spine_yaw,
			yaw_transfer_speed * delta
		)

func reset_spine(delta, spine_bone):
	spine_yaw = lerp_angle(spine_yaw, 0.0, spine_turn_speed * delta)
	apply_bone_yaw(spine_bone, spine_yaw)

func start_interaction() -> void:
	await get_tree().create_timer(.15).timeout
	if target != null:
		target.call("interact")
		text_interact.hide()
		interact_button.hide()
		_clear_movement()

# Removido porque laguea y anda mal en windows
func spawn_move_pointer(_new_position : Vector3) -> void:
	return 
	#var pointer_instance = CURSOR_POINTER.instantiate()
	#map.add_child(pointer_instance)
	#pointer_instance.global_position = new_position
	#pointer_instance.position.y = 0.5

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
		# set_animation_state(AnimationState.IDLE)
		pass
	
	if nav_agent.is_navigation_finished():
		var direction
		if target != null:
			direction = (target.global_position - global_position).normalized()
		else:
			direction = (target_position - global_position).normalized()
		direction.y = 0.0
		rotate_model(direction, delta)
		has_target = false
		moving_to_target = false
		should_run = false
		velocity = Vector3.ZERO
		# set_animation_state(AnimationState.IDLE)
		if global_position and pending_interactable:
			var distance = global_position.distance_to(pending_interactable.global_position)
			print(distance)
			if distance <= 2.0 and pending_interactable.has_method("interact"):
				target = pending_interactable
				pending_interactable = null
				start_interaction()
	
func rotate_model(direction: Vector3, delta: float) -> void:
	if abs(direction.dot(Vector3.UP)) > 0.98:
		return
	# print("Rotate to: ", direction)
	if direction != Vector3.ZERO:
		var target_basis = Basis.looking_at(direction, Vector3.UP)
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
	_play_sfx(CONTINUAR_HACHAZO_2)
	if not is_dialogue_active:
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
	_emit_step_particle()

func _on_timer_footsteps_timeout() -> void:
	play_sound_footsteps()


func _on_journal_button_pressed() -> void:
	# _play_sfx(CONTINUAR_HACHAZO_2)
	stop_highlight(journal_button)
	GameManager._toggle_journal()


func _on_pause_button_pressed() -> void:
	_play_sfx(SELECCIONAR_OPCIONES)
	_toogle_pause()

func _toogle_journal() -> void:
	stop_highlight(journal_button)
	if not is_journal_active:
		is_journal_active = true
		await get_tree().create_timer(0.4).timeout
		is_journal_active = false
		GameManager._toggle_journal()

func _toogle_pause() -> void:
	if not is_pause_active:
		is_pause_active = true
		await get_tree().create_timer(0.4).timeout
		is_pause_active = false
		GameManager._toggle_pause()

func start_first_dialogue() -> void:
	if not is_first_dialogue_done:
		set_animation_state(AnimationState.YAWN)
		# animation_player.play("Yawn/mixamo_com")
		await get_tree().create_timer(0.75).timeout
		DialogueManager.show_dialogue_balloon(first_dialogue, "start")

func _update_camera_avoidance(delta: float) -> void:
	return # faltan fixes
	if GameManager._is_game_paused():
		return

	if camera_avoid_cooldown >= 0.0:
		camera_avoid_cooldown -= delta

	var hit_length = spring_arm.get_hit_length()
	var is_colliding = hit_length < (spring_length - 0.1)
	var player_moved = global_position.distance_to(last_player_position) > 0.05
	last_player_position = global_position

	# Si colisiona y no estamos en cooldown, buscar siguiente posición libre
	if is_colliding and camera_avoid_cooldown <= 0.0:
		var next_index = _find_free_position()
		if next_index != camera_current_index:
			camera_current_index = next_index
			camera_target_y = camera_positions[next_index]
			camera_avoid_cooldown = 1.5
			camera_is_displaced = (next_index != 0)

	# Si el personaje se mueve y estamos desplazados, volver a la posición original
	if player_moved and camera_is_displaced:
		# Solo volver si la posición original no está bloqueada
		if not _is_position_blocked(0):
			camera_current_index = 0
			camera_target_y = camera_positions[0]
			camera_is_displaced = false
			camera_avoid_cooldown = 1.5

	# Interpolar suavemente — todo en grados, sin mezclar radianes
	camera_current_y = lerp(camera_current_y, camera_target_y, camera_rotation_speed * delta)

	# Snap cuando está muy cerca para evitar jitter
	if abs(camera_current_y - camera_target_y) < 0.1:
		camera_current_y = camera_target_y

	camera_pivot.rotation_degrees.y = camera_current_y


func _find_free_position() -> int:
	for i in range(1, camera_positions.size()):
		var test_index = (camera_current_index + i) % camera_positions.size()
		if not _is_position_blocked(test_index):
			return test_index
	return camera_current_index


func _is_position_blocked(index: int) -> bool:
	var space_state = get_world_3d().direct_space_state
	var test_angle = deg_to_rad(camera_positions[index])
	var pitch = spring_arm.rotation.x

	var cam_offset = Vector3(
		cos(pitch) * sin(test_angle) * spring_length,
		-sin(pitch) * spring_length,
		cos(pitch) * cos(test_angle) * spring_length
	)

	var from = global_position + Vector3(0, 1, 0)
	var to = from + cam_offset

	var query = PhysicsRayQueryParameters3D.create(from, to)
	query.exclude = [self]
	var result = space_state.intersect_ray(query)
	return result != null and result.size() > 0

func disable_look() -> void:
	look_enabled = false
	current_look_yaw = 0.0
	skeleton.clear_bones_global_pose_override()

func enable_look() -> void:
	current_look_yaw = 0.0
	look_enabled = true

func _emit_step_particle() -> void:
	gpu_particles_3d.restart()

func _on_registered_interaction(_interactable) -> void:
	highlight_button(journal_button)

func highlight_button(button: Button):
	var existing_tween = null
	if button.has_meta("highlight_tween"):
		existing_tween = button.get_meta("highlight_tween")
	if existing_tween and existing_tween.is_running():
		existing_tween.kill()
	
	button.scale = Vector2.ONE
	button.modulate = Color.WHITE
	
	var tween = button.create_tween()
	tween.set_loops()
	tween.set_parallel(true)
	
	# Scale (igual que antes pero un poco más pronunciado)
	tween.tween_property(button, "scale", Vector2(1.1, 1.1), 0.45)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(button, "scale", Vector2.ONE, 0.45)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN_OUT)\
		.set_delay(0.45)
	
	# Pulso de color cálido sincronizado con el scale
	tween.tween_property(button, "modulate", Color(1.9, 1.5, 0.5, 1.0), 0.45)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(button, "modulate", Color.WHITE, 0.45)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN_OUT)\
		.set_delay(0.45)
	button.set_meta("highlight_tween", tween)

func stop_highlight(button: Button):
	var tween = null
	if button.has_meta("highlight_tween"):
		tween = button.get_meta("highlight_tween")
	
	if tween and tween.is_running():
		tween.kill()
		button.modulate = Color.WHITE
		button.scale = Vector2.ONE
		button.set_meta("highlight_tween", null)
		print("anduvo!")
	
	button.scale = Vector2.ONE

func set_target_position(new_position : Vector3) -> void:
	if PATH_POSITION_CHAIN:
		target_positions.append(new_position)
	else:
		target_position = new_position
	nav_agent.set_target_position(target_position)
	has_target = true
	moving_to_target = false
	print("Target position: ", target_position)

func trigger_dialogue(diag : int, wait_time : float) -> void:
	match diag:
		3:
			await get_tree().create_timer(wait_time).timeout
			if has_target or moving_to_target:
				trigger_dialogue(3, 0.5)
			else:
				DialogueManager.show_dialogue_balloon(prototype03_dialogue, "start")


func _on_controls_button_pressed() -> void:
	_play_sfx(CONTINUAR_HACHAZO_2)
	if not is_pause_active:
		is_pause_active = true
		await get_tree().create_timer(0.4).timeout
		is_pause_active = false
		GameManager._toggle_controls()

func _play_sfx(sfx : Resource) -> void:
	sfx_stream_player.stream = sfx
	sfx_stream_player.play()

func _on_hover() -> void:
	sfx_stream_player.stream = HOVER
	sfx_stream_player.play()

func _on_dialogue_line(line) -> void:
	var balloon = get_tree().get_first_node_in_group("dialogue_balloon")
	if balloon:
		match line.text:
			"Margarita":
				# set_balloon_color(balloon, Color(0.2, 0.4, 0.8))
				pass

func _handle_hover() -> void:
	var camera = get_viewport().get_camera_3d()
	var from = camera.project_ray_origin(get_viewport().get_mouse_position())
	var to = from + camera.project_ray_normal(get_viewport().get_mouse_position()) * 1000
	var space_state = get_world_3d().direct_space_state

	var query = PhysicsRayQueryParameters3D.create(from, to, 1 << 3)
	query.collide_with_areas = true
	query.collide_with_bodies = true
	var result = space_state.intersect_ray(query)
	
	# print(result) # todavía falta corregir
	
	var new_hovered = null
	if result and result.has("collider") and result.has(""):
		var collider = result.collider
		if collider.has_method("glow"):
			new_hovered = collider

	# Si cambió el objeto hoovered
	if new_hovered != hovered_interactable:
		if hovered_interactable != null and hovered_interactable.has_method("glow"):
			hovered_interactable.glow(false)  # apagar el anterior
		if new_hovered != null:
			new_hovered.glow(true)  # encender el nuevo
		hovered_interactable = new_hovered

func set_first_dialogue_state() -> void:
	is_first_dialogue_done = true
