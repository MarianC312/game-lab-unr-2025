extends Node3D

@onready var first_interaction_area_3d: Area3D = $Triggers/FirstInteractionArea3D
const BARTENDER_FST_INTERACTION : DialogueResource = preload("res://Dialogues/Scene/Prototype02/BartenderFstInteraction.dialogue")
var player
var already_interacted := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_first_interaction_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("Player") and not already_interacted:
		body._reset_movement_state()
		already_interacted = true
		DialogueManager.show_dialogue_balloon(BARTENDER_FST_INTERACTION)
