extends CharacterBody3D

@export var npc_name : String = ""
@export var dialogue : DialogueResource = preload("res://Dialogues/Default/Default.dialogue")
@export var map := "Mapa01"
@export var photo := preload("res://Textures/Journal_item_photo_placeholder.png")
@export_multiline var text_content : String = "Lorem ipsum..."
@export var required := true
@export var glow: bool = false:
	set(value):
		glow = value
		if value:
			show_highlight()
		else:
			hide_highlight()
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var armature: Skeleton3D = $Armature/Skeleton3D

@export var highlight_shader : Shader = preload("res://Shaders/glow_effect05.gdshader") # def: 01
var highlight_surfaces: Array = []
var highlight_material: ShaderMaterial
var is_dialogue_active : bool = false

enum AnimationState {IDLE, WALKING, RUNNING, TALKING}
var play_animation_state : AnimationState = AnimationState.IDLE

var _locked_armature_position: Vector3

func _ready() -> void:
	DialogueManager.dialogue_started.connect(_on_dialogue_start)
	DialogueManager.dialogue_ended.connect(_on_dialogue_end)
	_locked_armature_position = Vector3(0.0, 0.0, 0.5)
	for child in armature.get_children():
		if child is MeshInstance3D:
			_setup_highlight_surface(child)

func _physics_process(_delta: float) -> void:
	print(global_position)
	if animation_player.current_animation == "Bartending/mixamo_com":
		print(global_position)
		print(_locked_armature_position)
		armature.position = _locked_armature_position
	else:
		armature.position = Vector3.ZERO

func _setup_highlight_surface(mesh: MeshInstance3D):
	var mat = ShaderMaterial.new()
	mat.render_priority = 120
	mat.shader = highlight_shader
	mat.set_shader_parameter("intensity", 1.2)
	mat.set_shader_parameter("outline_width", 0.015)
	mat.set_shader_parameter("pulse_speed", 1.0)
	
	var surface_count = mesh.mesh.get_surface_count()
	var original_mat = mesh.get_surface_override_material(surface_count - 1)
	
	highlight_surfaces.append({
		"mesh": mesh,
		"material": mat,
		"original": original_mat,
		"index": surface_count - 1
	})

func interact() -> void:
	print("Interacted with: ", npc_name)
	DialogueManager.show_dialogue_balloon(dialogue)

#func _create_highlight_mesh(source_mesh: MeshInstance3D):
	#var mat = ShaderMaterial.new()
	#mat.render_priority = 120
	#mat.shader = highlight_shader
#
	#var h_mesh = MeshInstance3D.new()
	#h_mesh.set_as_top_level(true)
	#h_mesh.global_transform = source_mesh.global_transform
	#h_mesh.mesh = source_mesh.mesh
	#h_mesh.material_override = mat
	#h_mesh.visible = false
	#source_mesh.add_child(h_mesh)
	## get_tree().root.add_child(h_mesh)
	#h_mesh.global_transform = global_transform
	#highlight_meshes.append({
		#"highlight": h_mesh,
		#"source": source_mesh
	#})
	#print("mesh: ", source_mesh.name, " | mesh nulo: ", source_mesh.mesh == null, " | shader nulo: ", highlight_shader == null)

func _on_dialogue_start(_dialogue) -> void:
	# play_animation_state = AnimationState.TALKING
	is_dialogue_active = true

func _on_dialogue_end(_dialogue) -> void:
	# play_animation_state = AnimationState.IDLE
	await get_tree().create_timer(0.2).timeout
	is_dialogue_active = false

func get_npc_name() -> String:
	return npc_name

func show_highlight():
	for entry in highlight_surfaces:
		entry["mesh"].set_surface_override_material(entry["index"], entry["material"])

func hide_highlight():
	for entry in highlight_surfaces:
		entry["mesh"].set_surface_override_material(entry["index"], entry["original"])

func _glow(status: bool) -> void:
	glow = status
	if glow:
		await get_tree().create_timer(3.5).timeout
		glow = false

func is_glowing() -> bool:
	return glow
