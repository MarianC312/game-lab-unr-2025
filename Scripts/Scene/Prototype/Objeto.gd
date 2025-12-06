extends StaticBody3D

@export var object_name : String = ""
@export var dialogue : DialogueResource = preload("res://Dialogues/Default/Default.dialogue")
@export var object_mesh : MeshInstance3D

var is_dialogue_active : bool = false
var highlight_shader : Shader = preload("res://Shaders/glow_effect.gdshader")
var highlight_mesh: MeshInstance3D
var highlight_material: ShaderMaterial
var glow : bool = false
var load_next_scene_after_dialogue : bool = false

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

func _glow(status : bool) -> void:
	glow = status

func interact() -> void:
	print("Interacted with: ", object_name)
	DialogueManager.show_dialogue_balloon(dialogue, "start")

func _on_dialogue_start(_dialogue) -> void:
	is_dialogue_active = true

func _on_dialogue_end(_dialogue) -> void:
	await get_tree().create_timer(0.2).timeout
	is_dialogue_active = false
	#if object_name == "Puerta04":
		#await get_tree().create_timer(0.75).timeout
		#GameManager.load_new_map("res://Scenes/Prototype/Prototype02.tscn")
