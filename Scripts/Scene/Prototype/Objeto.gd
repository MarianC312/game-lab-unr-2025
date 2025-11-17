extends Area3D

@export var object_name : String = ""
@export var dialogue : DialogueResource = preload("res://Dialogues/Default/Default.dialogue")
var is_dialogue_active : bool = false

func interact() -> void:
	print("Interacted with: ", object_name)
	DialogueManager.show_dialogue_balloon(dialogue, "start", [object_name])

func _on_dialogue_start(dialogue) -> void:
	is_dialogue_active = true

func _on_dialogue_end(dialogue) -> void:
	await get_tree().create_timer(0.2).timeout
	is_dialogue_active = false
