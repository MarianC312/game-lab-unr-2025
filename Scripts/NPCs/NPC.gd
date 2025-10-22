extends StaticBody3D

@export var npc_name : String = ""
@export var dialogue : DialogueResource = preload("res://Dialogues/Default/Default.dialogue")

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	pass

func interact() -> void:
	print("Interacted with: ", npc_name)
	DialogueManager.show_dialogue_balloon(dialogue, "start")
