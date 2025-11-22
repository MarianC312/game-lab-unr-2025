extends Area3D

@export var object_name : String = ""
@export var dialogue : DialogueResource = preload("res://Dialogues/Default/Default.dialogue")
@export var object_mesh : MeshInstance3D

var is_dialogue_active : bool = false
var highlight_material : StandardMaterial3D = preload("res://Materials/Interactable_glow.tres")

var load_next_scene_after_dialogue : bool = false

func _ready() -> void:
	get_tree().get_first_node_in_group("Player")

func glow(status : bool) -> void:
	if status:
		object_mesh.material_overlay = highlight_material
	else:
		object_mesh.material_overlay = null

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
