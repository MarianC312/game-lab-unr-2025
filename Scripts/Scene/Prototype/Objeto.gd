extends StaticBody3D

@export var object_name : String = ""
@export var dialogue : DialogueResource = preload("res://Dialogues/Default/Default.dialogue")
@export var object_mesh : MeshInstance3D
@export var has_minigame := false
@export var minigame : Resource
@export var locked := false
@export var despawn := false
@export var required := true
@export var map := "Mapa01"
@export var photo := preload("res://Textures/Journal_item_photo_placeholder.png")
@export var text_content := "Lorem ipsum..."
@export var should_highlight := true

var is_dialogue_active : bool = false
var highlight_shader : Shader = preload("res://Shaders/glow_effect01.gdshader")
var highlight_mesh: MeshInstance3D
var highlight_material: ShaderMaterial
var glow : bool = false
var load_next_scene_after_dialogue : bool = false
var minigame_instance

func _ready() -> void:
	get_tree().get_first_node_in_group("Player")
	object_mesh = get_parent()
	highlight_material = ShaderMaterial.new()
	highlight_material.render_priority = 120
	highlight_material.shader = highlight_shader
	highlight_mesh = MeshInstance3D.new()
	highlight_mesh.set_as_top_level(true)
	highlight_mesh.global_transform = object_mesh.global_transform
	highlight_mesh.mesh = object_mesh.mesh
	highlight_mesh.material_override = highlight_material
	highlight_mesh.visible = false
	add_child(highlight_mesh)

func _process(_delta: float) -> void:
	if glow:
		highlight_mesh.visible = true
	else:
		highlight_mesh.visible = false

func despawn_on_interaction() -> bool:
	return despawn

func despawn_object() -> void:
	get_parent().visible = false
	get_parent().process_mode = Node.PROCESS_MODE_DISABLED
	# get_parent().queue_free()

func _glow(status : bool) -> void:
	if should_highlight and not SceneManagerMap01._already_interacted(object_name) or not SceneManagerMap02._already_interacted(object_name) or not SceneManagerMap03._already_interacted(object_name) or not SceneManagerMap04._already_interacted(object_name):
		glow = status
		await get_tree().create_timer(1.5).timeout
		glow = false

func is_glowing() -> bool:
	return glow

func interact() -> void:
	print("Interacted with: ", object_name)
	DialogueManager.show_dialogue_balloon(dialogue, "start")

func is_locked() -> bool:
	return locked

func unlock() -> void:
	locked = false
	SceneManagerMap01._register_interaction(object_name)
	interact()

func get_minigame() -> Resource:
	return minigame

func _on_dialogue_start(_dialogue) -> void:
	is_dialogue_active = true

func get_object_name() -> String:
	return object_name

func _on_dialogue_end(_dialogue) -> void:
	await get_tree().create_timer(0.2).timeout
	is_dialogue_active = false
	#if object_name == "Puerta04":
		#await get_tree().create_timer(0.75).timeout
		#GameManager.load_new_map("res://Scenes/Prototype/Prototype02.tscn")
