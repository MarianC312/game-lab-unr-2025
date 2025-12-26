extends Control

@export var dialogue : DialogueResource

func _ready() -> void:
	pass

func start_dialogue() -> void:
	await get_tree().create_timer(0.75).timeout
	DialogueManager.show_dialogue_balloon(dialogue, "start")
