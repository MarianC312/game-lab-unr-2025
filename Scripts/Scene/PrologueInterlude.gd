extends Control

@export var dialogue : DialogueResource = preload("res://Dialogues/Default/Default.dialogue")

func _ready() -> void:
	start_dialogue()

func start_dialogue() -> void:
	await get_tree().create_timer(0.75).timeout
	DialogueManager.show_dialogue_balloon(dialogue, "start")
