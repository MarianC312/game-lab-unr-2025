extends Node3D

const BARTENDER_FST_INTERACTION : DialogueResource = preload("res://Dialogues/Scene/Prototype02/BartenderFstInteraction.dialogue")
const AREA_PELIGROSA : DialogueResource = preload("res://Dialogues/Scene/Prototype02/AreaPeligrosa.dialogue")
var already_interacted_bartender := false
var already_chusmieited := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_first_interaction_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("Player") and not already_interacted_bartender:
		body._reset_movement_state()
		already_interacted_bartender = true
		DialogueManager.show_dialogue_balloon(BARTENDER_FST_INTERACTION)


func _on_danger_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		body._reset_movement_state()
		already_chusmieited = true
		DialogueManager.show_dialogue_balloon(AREA_PELIGROSA, "start", [self, {"already_chusmieited": already_chusmieited}])
		
